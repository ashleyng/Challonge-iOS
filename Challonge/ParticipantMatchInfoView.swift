//
//  ParticipantMatchInfoView.swift
//  Challonge
//
//  Created by Ashley Ng on 12/15/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import Foundation
import UIKit
import ChallongeNetworking

@IBDesignable
class ParticipantMatchInfoView: UIView {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var participantNameLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var votesLabel: UILabel!
    
    private var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: ParticipantMatchInfoView.identifier, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    func setup(match: Match, participant: Participant) {
        participantNameLabel.text = participant.name
        scoreLabel.text = match.scoresCsv
    }
}

