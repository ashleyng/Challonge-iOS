//
//  SingleMatchViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking
import Crashlytics

class SingleMatchViewController: UIViewController {

    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var playerOneView: ParticipantMatchInfoView!
    @IBOutlet private var playerTwoView: ParticipantMatchInfoView!
    @IBOutlet private var inputScoreButton: UIButton!
    @IBOutlet private var startMatchButton: UIButton!
    
    private let match: Match
    private let playerOne: Participant
    private let playerTwo: Participant
    private let networking: ChallongeNetworking
    
    init(match: Match, playerOne: Participant, playerTwo: Participant, networking: ChallongeNetworking) {
        self.match = match
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.networking = networking
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Match #\(match.suggestedPlayOrder)"
        
        inputScoreButton.roundEdges(withRadius: 10)
        startMatchButton.roundEdges(withRadius: 10)
        
        playerOneView.setup(match: match, participant: playerOne)
        playerTwoView.setup(match: match, participant: playerTwo)
        
        loadingIndicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        networking.getSingleMatchForTournament(match.tournamentId, matchId: match.id, completion: { [weak self] match in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.playerOneView.refresh(with: match)
                self.playerTwoView.refresh(with: match)
            }
        }, onError: nil)
    }

    @IBAction func startMatchPressed(_ sender: UIButton) {
        navigationController?.pushViewController(PlayingMatchViewController(match: match, player1: playerOne, player2: playerTwo, networking: networking), animated: true)
    }

    @IBAction func inputScorePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Input Score", message: nil, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Player 1 Score"
        }

        alert.addTextField { textField in
            textField.placeholder = "Player 2 Score"
        }

        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert, weak self] _ in
            guard let `self` = self,
                let textFields = alert?.textFields,
                let player1Score = textFields[0].text,
                let player2Score = textFields[1].text,
                let player1Id = self.match.player1Id,
                let player2Id = self.match.player2Id else {
                    return
            }
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.loadingIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.6)

            let winnerId = player1Score > player2Score ? player1Id : player2Id
            self.networking.setWinnerForMatch(self.match.tournamentId, matchId: self.match.id, winnderId: winnerId, score: "\(player1Score)-\(player2Score)", completion: { match in
                DispatchQueue.main.async {
                    self.loadingIndicator.isHidden = true
                    self.loadingIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.playerOneView.refresh(with: match)
                    self.playerTwoView.refresh(with: match)
                }
            }, onError: { error in
                Answers.logCustomEvent(withName: "ErrorSubmittingScore", customAttributes: [
                    "Error": error.localizedDescription
                ])
                DispatchQueue.main.async {
                    self.loadingIndicator.isHidden = true
                    self.loadingIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
            })
        }))
        present(alert, animated: true, completion: nil)
    }
}
