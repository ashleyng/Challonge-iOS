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

    @IBOutlet private var playersLabel: UILabel!
    @IBOutlet private var matchStatuslabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureWith(_ match: Match, label: String) {
        playersLabel.text = label
        matchStatuslabel.text = match.state == .complete ? match.scoresCsv : match.state.rawValue
    
        switch match.state {
        case .complete:
            matchStatuslabel.textColor = UIColor.completedGreen
        case .open:
            matchStatuslabel.textColor = UIColor.gray
        case .pending:
            matchStatuslabel.textColor = UIColor.red
        }
    }
}
