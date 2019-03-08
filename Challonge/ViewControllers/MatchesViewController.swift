//
//  MatchesViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking
import Crashlytics

fileprivate enum State {
    case loading
    case populated([Match], [Int: Participant], [Int: Int])
    case empty
    case error(Error)

    var currentMatches: [Match] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let matches, _, _):
            return matches
        }
    }

    var currentParticipants: [Int: Participant] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(_, let participants, _):
            return participants
        }
    }
    
    var groupParticipantIds: [Int: Int] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(_, _, let participants):
            return participants
        }
    }
}

class MatchesViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    private let networking: ChallongeNetworking
    private let tournamentName: String
    private let tournamentId: Int
    private var state = State.loading {
        didSet {
            updateUI()
        }
    }
    
    init(challongeNetworking: ChallongeNetworking, tournament: Tournament) {
        networking = challongeNetworking
        tournamentName = tournament.name
        tournamentId = tournament.id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = tournamentName
        updateUI()

        tableView.register(UINib(nibName: MatchTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: MatchTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshMatches(_:)), for: .valueChanged)
        
        fetchTournament()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTournament()
    }

    @objc
    private func refreshMatches(_ sender: Any) {
        fetchTournament()
    }

    private func fetchTournament() {
        networking.getMatchesForTournament(tournamentId, completion: { matches in
            self.fetchParticipants() { participants in
                let participantsDict = participants.toDictionary { $0.id.main }
                let sortedMatches = matches.sorted(by: { left, right in
                    // TODO need to check these bools
                    guard let leftSuggestedPlayOrder = left.suggestedPlayOrder else {
                        return false
                    }
                    guard let rightSuggestedPlayOrder = right.suggestedPlayOrder else {
                        return true
                    }
                    return leftSuggestedPlayOrder < rightSuggestedPlayOrder
                })
                self.state = .populated(sortedMatches, participantsDict, self.mapGroupIds(participants: participantsDict))
            }
        }, onError: { error in
            self.state = .error(error)
        })
    }

    private func fetchParticipants(completion: @escaping ([Participant]) -> Void) {
        networking.getParticipantsForTournament(tournamentId, completion: { (participants: [Participant]) in
            completion(participants)
        }, onError: { _ in })
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            switch self.state {
            case .empty, .populated:
                self.tableView.isHidden = false
                self.loadingIndicator.isHidden = true
                self.refreshControl.endRefreshing()
                self.loadingIndicator.stopAnimating()
            case .error(let error):
                print("Error: \(error.localizedDescription)")
                Answers.logCustomEvent(withName: "ErrorFetchingMatches", customAttributes: [
                    "Error": error.localizedDescription
                ])
            case .loading:
                self.tableView.isHidden = true
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
            }
            self.tableView.reloadData()
        }
    }
    
    private func mapGroupIds(participants: [Int: Participant]) -> [Int: Int] {
        var dict = [Int: Int]()
        participants.forEach { (participantId, participant) in
            participant.id.all.forEach{ groupId in
                dict[groupId] = participantId
            }
        }
        return dict
    }
}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.currentMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matches = state.currentMatches
        let match = matches[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell {
            cell.configureWith(match, label: matchCellLabel(player1Id: match.player1Id, player2Id: match.player2Id, suggestedPlayOrder: match.suggestedPlayOrder ?? 1))
            return cell
        }
        return MatchTableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let match = state.currentMatches[indexPath.row]
        guard let playerOneId = match.player1Id, let playerTwoId = match.player2Id,
            let player1 = getParticipan(id: playerOneId), let player2 = getParticipan(id: playerTwoId) else {
            unsupportedTournamentType()
            return
        }
        
        navigationController?.pushViewController(SingleMatchDetailsViewController(match: match, playerOne: player1, playerTwo: player2, networking: networking), animated: true)
    }

    private func matchCellLabel(player1Id: Int?, player2Id: Int?, suggestedPlayOrder: Int) -> String{
        guard let player1Id = player1Id, let player2Id = player2Id else {
            return "Match \(suggestedPlayOrder)"
        }
        let player1 = getPlayerName(id: player1Id)
        let player2 = getPlayerName(id: player2Id)
        return "\(player1) vs. \(player2)"
    }
    
    private func getPlayerName(id: Int) -> String {
        let participants = state.currentParticipants
        if let name = participants[id]?.name {
            return name
        } else if let groupId = state.groupParticipantIds[id], let name = participants[groupId]?.name {
            return name
        } else {
            return "Unknown Player"
        }
    }
    
    private func getParticipan(id: Int) -> Participant? {
        let participants = state.currentParticipants
        if let participant = participants[id] {
            return participant
        } else if let groupId = state.groupParticipantIds[id], let participant = participants[groupId] {
            return participant
        } else {
            return nil
        }
    }

    private func unsupportedTournamentType() {
        let alertController = UIAlertController(title: nil, message: "We currently don't support viewing this match, but don't fret, we're are always working on improving user experience and adding new features.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
