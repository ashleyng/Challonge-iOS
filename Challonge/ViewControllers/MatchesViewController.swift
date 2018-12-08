//
//  MatchesViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

fileprivate enum State {
    case loading
    case populated([Match], [Int: Participant])
    case empty
    case error(Error)

    var currentMatches: [Match] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let matches, _):
            return matches
        }
    }

    var currentParticipants: [Int: Participant] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(_, let participants):
            return participants
        }
    }
}

class MatchesViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var tournamentNameLabel: UILabel!
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

        tableView.register(UINib(nibName: "MatchTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchCell")

        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshMatches(_:)), for: .valueChanged)

        tournamentNameLabel.text = tournamentName
        updateUI()
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
                self.state = .populated(matches, participants.toDictionary { $0.id })
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
            case .loading:
                self.tableView.isHidden = true
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.currentMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matches = state.currentMatches
        let match = matches[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as? MatchTableViewCell {
            cell.configureWith(match, label: matchCellLabel(player1Id: match.player1Id, player2Id: match.player2Id, suggestedPlayOrder: match.suggestedPlayOrder))
            return cell
        }
        return MatchTableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let match = state.currentMatches[indexPath.row]
        present(SingleMatchViewController(match: match, networking: networking), animated: true, completion: nil)
    }

    private func matchCellLabel(player1Id: Int?, player2Id: Int?, suggestedPlayOrder: Int) -> String{
        guard let player1Id = player1Id, let player2Id = player2Id else {
            return "Match \(suggestedPlayOrder)"
        }
        let participants = state.currentParticipants
        let player1 = participants[player1Id]?.name ?? "Unknown Player 1"
        let player2 = participants[player2Id]?.name ?? "Unknown Player 2"

        return "\(player1) vs. \(player2)"
    }
}


