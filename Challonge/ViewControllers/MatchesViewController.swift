//
//  MatchesViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class MatchesViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var tournamentNameLabel: UILabel!
    
    private let networking: ChallongeNetworking
    private let tournamentName: String
    private let tournamentId: Int
    private var matches: [Match] = []
    private var participants: [Int: Participant] = [:]
    private var matchFetchComplete: Bool = false {
        didSet {
            if !oldValue && matchFetchComplete && participantFetchComplete {
                self.tableView.reloadData()
            }
        }
    }
    private var participantFetchComplete: Bool = false {
        didSet {
            if !oldValue && participantFetchComplete && matchFetchComplete {
                self.tableView.reloadData()
            }
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
        
        tableView.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        
        tournamentNameLabel.text = tournamentName
        fetchTournament()
    }
    
    private func fetchTournament() {
        networking.getMatchesForTournament(tournamentId, completion: { matches in
            self.matches = matches
            self.fetchParticipants()

        }, onError: { error in
            print("errored matches")
            print(error.localizedDescription)
        })
    }
    
    private func fetchParticipants() {
        networking.getParticipantsForTournament(tournamentId, completion: { (participants: [Participant]) in
            self.participants = participants.toDictionary { $0.id }
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
                self.tableView.reloadData()
            }
            
        }, onError: { _ in })
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let match = matches[indexPath.row]
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


