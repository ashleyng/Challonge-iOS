//
//  SingleMatchViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class SingleMatchViewController: UIViewController {

    private let match: Match
    private let networking: ChallongeNetworking

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    init(match: Match, networking: ChallongeNetworking) {
        self.match = match
        self.networking = networking
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func startMatchPressed(_ sender: UIButton) {
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

            self.networking.setWinnerForMatch(self.match.tournamentId, matchId: self.match.id, winnderId: player1Id, score: "\(player1Score)-\(player2Score)", completion: { match in
                print("SCORE SUBMITTED for: \(match.id) \(match.player1Id) \(match.winnerId) \(match.scoresCsv)")
            }, onError: { error in
                print("EEEEERRRROROOORRR: \(error.localizedDescription)")
            })
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
