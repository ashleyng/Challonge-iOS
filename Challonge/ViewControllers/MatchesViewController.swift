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

        tableView.delegate = self
        tableView.dataSource = self
        
        tournamentNameLabel.text = tournamentName
        updateUI()
        fetchTournament()
    }
    
    private func fetchTournament() {
        networking.getMatchesForTournament(tournamentId, completion: { matches in
            self.fetchParticipants() { participants in
                self.state = .populated(matches, participants.toDictionary { $0.id })
            }

        }, onError: { error in
            print("errored matches")
            print(error.localizedDescription)
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
        let cell = UITableViewCell()
        let matches = state.currentMatches
        let match = matches[indexPath.row]
        let participants = state.currentParticipants
        var player1 = ""
        var player2 = ""
        
        guard let player1Id = match.player1Id, let player2Id = match.player2Id else {
            cell.textLabel?.text = "Match \(match.suggestedPlayOrder)"
            return cell
        }
        
        player1 = participants[player1Id]?.name ?? "Unknown Player 1"
        player2 = participants[player2Id]?.name ?? "Unknown Player 2"

        cell.textLabel?.text = "\(player1) vs. \(player2)"
        return cell
    }
}


