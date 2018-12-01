//
//  TournamentTableViewCell.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class TournamentTableViewCell: UITableViewCell {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWith(_ tournament: Tournament) {
        self.nameLabel.text = tournament.name
        self.statusLabel.text = tournament.state.readableStatus
        switch tournament.state {
        case .pending:
            self.statusLabel?.textColor = UIColor.gray
        case .complete:
            self.statusLabel.textColor = UIColor.green
        case .underway, .awaiting_review:
            self.statusLabel.textColor = UIColor.red
        }
    }
}
