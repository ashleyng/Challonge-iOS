//
//  MatchTableViewCell.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class MatchTableViewCell: UITableViewCell {

    @IBOutlet private var matchLabel: UILabel!
    @IBOutlet private var player1Name: UILabel!
    @IBOutlet private var player1Status: UILabel!
    @IBOutlet private var player2Name: UILabel!
    @IBOutlet private var player2Status: UILabel!
    @IBOutlet private var singleStatus: UILabel!
    @IBOutlet private var outerView: UIView!
    
    private enum Constants {
        static let borderRadius: CGFloat = 5
        static let borderColor: UIColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
        static let borderWidth: CGFloat = 1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBorder()
        setupMatchLabel()
    }

    func configureWith(_ matchViewModel: MatchViewModel) {
        setupTextLabels(with: matchViewModel)
        setupVisibleStatusLabels(with: matchViewModel.state)
    }
    
    private func setupBorder() {
        outerView.layer.borderWidth = Constants.borderWidth
        outerView.layer.cornerRadius = Constants.borderRadius
        outerView.layer.borderColor = Constants.borderColor.cgColor
    }
    
    private func setupMatchLabel() {
        self.matchLabel.backgroundColor = Constants.borderColor
        self.matchLabel.textColor = .white
        self.matchLabel.clipsToBounds = true
        self.matchLabel.layer.cornerRadius = Constants.borderRadius
        self.matchLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func setupTextLabels(with viewModel: MatchViewModel) {
        matchLabel.text = viewModel.matchLabel()
        player1Name.text = viewModel.nameFor(player: .playerOne)
        player2Name.text = viewModel.nameFor(player: .playerTwo)
        
        singleStatus.text = viewModel.matchStatus()
        singleStatus.textColor = viewModel.statusLabelColor()
        
        player1Status.text = viewModel.statusFor(player: .playerOne)
        player2Status.text = viewModel.statusFor(player: .playerTwo)
        player1Status.textColor = viewModel.statusLabelColor()
        player2Status.textColor = viewModel.statusLabelColor()
    }
    
    private func setupVisibleStatusLabels(with state: MatchViewModel.CellState) {
        switch state {
            case .noScore:
                singleStatus.isHidden = false
                player1Status.isHidden = true
                player2Status.isHidden = true
            case .hasScore:
                singleStatus.isHidden = true
                player1Status.isHidden = false
                player2Status.isHidden = false
        }
    }
}
