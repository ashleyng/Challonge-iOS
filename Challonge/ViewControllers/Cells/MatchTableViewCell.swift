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

    func configureWith(_ matchViewModel: MatchTableViewCellViewModel) {
        playersLabel.text = matchViewModel.matchLabel()
        matchStatuslabel.text = matchViewModel.matchStatusLabelText()
        
        matchStatuslabel.textColor = matchViewModel.statusLabelColor()
    }
}
