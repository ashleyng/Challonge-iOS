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
    private var participant: Participant?
    
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
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        return view
    }
    
    func setup(match: Match, participant: Participant) {
        self.participant = participant
        participantNameLabel.text = participant.name
        if let score = match.score(for: participant.id) {
            scoreLabel.text = score
        }
        
        if let votes = match.vote(for: participant.id) {
            votesLabel.text = "\(votes)"
        }
        
        if let icon = participant.icon {
            avatarImageView.downloaded(from: icon)
        } else {
            avatarImageView.downloaded(from: "https://api.adorable.io/avatars/face/eyes9/nose2/mouth11/ED1F16")
        }
    }
    
    func refresh(with match: Match) {
        if let participant = participant, let score = match.score(for: participant.id) {
            scoreLabel.text = score
        }
    }
}

