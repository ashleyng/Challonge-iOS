//
//  PlayingMatchViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking
import Crashlytics

class PlayingMatchViewController: UIViewController {
    
    @IBOutlet private var player1ScoreLabel: UILabel!
    @IBOutlet private var player2ScoreLabel: UILabel!
    @IBOutlet private var pointPlayer1Button: UIButton!
    @IBOutlet private var pointPlayer2Button: UIButton!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var player1Label: UILabel!
    @IBOutlet private var player2Label: UILabel!
    
    private var player1Score: Int = 0 {
        didSet {
            player1ScoreLabel.text = "\(player1Score)"
        }
    }
    
    private var player2Score: Int = 0 {
        didSet {
            player2ScoreLabel.text = "\(player2Score)"
        }
    }
    
    private let networking: ChallongeNetworking
    private let match: Match
    private let player1: Participant
    private let player2: Participant
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    init(match: Match, player1: Participant, player2: Participant, networking: ChallongeNetworking) {
        self.match = match
        self.player1 = player1
        self.player2 = player2
        self.networking = networking
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Submit", style: .done, target: self , action: #selector(submitScore(_:))), animated: false)
        
        pointPlayer1Button.roundEdges(withRadius: 10)
        pointPlayer2Button.roundEdges(withRadius: 10)
        undoButton.roundEdges(withRadius: 10)
        
        player1Label.text = player1.name
        player2Label.text = player2.name
    }
    
    @objc
    private func submitScore(_ sender: Any) {
        let winnerId = player1Score > player2Score ? player1.id : player2.id
        let alert = createSubmitScoreAlert(winnerId: winnerId)
        present(alert, animated: true, completion: nil)
    }
    
    private func createSubmitScoreAlert(winnerId: Int) -> UIAlertController {
        let alert = UIAlertController(title: "Submit Score", message: "Are you sure you want to submit this score?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.networking.setWinnerForMatch(self.match.tournamentId, matchId: self.match.id, winnderId: winnerId, score: "\(self.player1Score)-\(self.player2Score)", completion: { match in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }, onError: { error in
                Answers.logCustomEvent(withName: "ErrorSubmittingScore", customAttributes: [
                    "Error": error.localizedDescription
                    ])
            })
        }))
        return alert
    }
    
    @IBAction func pointPlayerOnePressed(_ sender: Any) {
        player1Score += 1
    }
    
    @IBAction func pointPlayerTwoPressed(_ sender: Any) {
        player2Score += 1
    }
    
}
