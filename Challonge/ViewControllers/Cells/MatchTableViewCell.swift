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
    
    private var customBorder: UIView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCustomBorder()
        setupMatchLabel()
    }

    func configureWith(_ matchViewModel: MatchTableViewCellViewModel) {
        setupTextLabels(with: matchViewModel)
        setupVisibleStatusLabels(with: matchViewModel.state)
    }
    
    private func setupCustomBorder() {
        addSubview(customBorder)
        
        customBorder.snp.makeConstraints { make in
            make.bottom.right.left.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        
        customBorder.layer.borderWidth = 1
        customBorder.layer.cornerRadius = 5
        customBorder.layer.borderColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1).cgColor
    }
    
    private func setupMatchLabel() {
        self.matchLabel.backgroundColor = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1)
        self.matchLabel.textColor = .white
        self.matchLabel.clipsToBounds = true
        self.matchLabel.layer.cornerRadius = 5
        self.matchLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func setupTextLabels(with viewModel: MatchTableViewCellViewModel) {
        matchLabel.text = viewModel.matchLabel()
        player1Name.text = viewModel.playerOneName()
        player2Name.text = viewModel.playerTwoName()
        
        singleStatus.text = viewModel.matchStatus()
        singleStatus.textColor = viewModel.statusLabelColor()
        
        player1Status.text = viewModel.playerOneStatus()
        player2Status.text = viewModel.playerTwoStatus()
        player1Status.textColor = viewModel.statusLabelColor()
        player2Status.textColor = viewModel.statusLabelColor()
    }
    
    private func setupVisibleStatusLabels(with state: MatchTableViewCellViewModel.CellState) {
        
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
