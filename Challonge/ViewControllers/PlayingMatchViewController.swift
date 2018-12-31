//
//  PlayingMatchViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class PlayingMatchViewController: UIViewController {
    
    @IBOutlet private var player1ScoreLabel: UILabel!
    @IBOutlet private var player2ScoreLabel: UILabel!
    @IBOutlet private var pointPlayer1Button: UIButton!
    @IBOutlet private var pointPlayer2Button: UIButton!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var player1Label: UILabel!
    @IBOutlet private var player2Label: UILabel!
    
    private let playingViewModel: PlayingMatchViewModel
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    init(match: Match, player1: Participant, player2: Participant, networking: ChallongeNetworking) {
        self.playingViewModel = PlayingMatchViewModel(match: match, player1: player1, player2: player2, challongeNetworking: networking)
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
        undoButton.isEnabled = playingViewModel.canUndo()
        
        player1Label.text = playingViewModel.getPlayerOneName()
        player2Label.text = playingViewModel.getPlayerTwoName()
    }
    
    @objc
    private func submitScore(_ sender: Any) {
        let alert = createSubmitScoreAlert()
        present(alert, animated: true, completion: nil)
    }
    
    private func createSubmitScoreAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Submit Score", message: "Are you sure you want to submit this score?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            self?.playingViewModel.submitScore() {
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }))
        return alert
    }
    
    @IBAction func pointPlayerOnePressed(_ sender: Any) {
        let score = playingViewModel.increaseScoreForPlayerOne()
        updateScore(scoreTuple: score)
    }
    
    @IBAction func pointPlayerTwoPressed(_ sender: Any) {
        let score = playingViewModel.increaseScoreForPlayerTwo()
        updateScore(scoreTuple: score)
    }
    
    @IBAction func undoPressed(_ sender: Any) {
        let score = playingViewModel.undoScore()
        updateScore(scoreTuple: score)
    }
    
    private func updateScore(scoreTuple: (player1: Int, player2: Int)) {
        undoButton.isEnabled = playingViewModel.canUndo()
        player1ScoreLabel.text = "\(scoreTuple.player1)"
        player2ScoreLabel.text = "\(scoreTuple.player2)"
    }
}
