//
//  MatchTableViewCellViewModel.swift
//  Challonge
//
//  Created by Ashley Ng on 2/24/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking

struct MatchTableViewCellViewModel {
    private let match: Match
    private let player1: Participant?
    private let player2: Participant?
    
    init(match: Match, participants: [Int: Participant], groupParticipantIds: [Int: Int]) {
        self.match = match
        self.player1 = MatchTableViewCellViewModel.getPlayer(with: match.player1Id, participants: participants, groupParticipantIds: groupParticipantIds)
        self.player2 = MatchTableViewCellViewModel.getPlayer(with: match.player2Id, participants: participants, groupParticipantIds: groupParticipantIds)
    }
    
    func matchLabel() -> String {
        let player1 = self.player1
        let player2 = self.player2
        
        if player1 == nil && player2 == nil {
            if let matchNumber = match.suggestedPlayOrder {
                return "Match \(matchNumber)"
            }
            return "Unknown Match#"
        }

        let player1Name = player1?.name ?? "Unknown Player"
        let player2Name = player2?.name ?? "Unknown Player"
        return "\(player1Name) vs. \(player2Name)"
    }
    
    // TODO: Fix this optional string. seems weird to be optional
    func matchStatusLabelText() -> String? {
        return match.state == .complete ? match.scoresCsv : match.state.rawValue
    }
    
    func statusLabelColor() -> UIColor {
        switch match.state {
        case .complete:
            return UIColor.completedGreen
        case .open:
            return UIColor.gray
        case .pending:
            return UIColor.red
        }
    }
    
    private static func getPlayer(with id: Int?, participants: [Int: Participant], groupParticipantIds: [Int: Int]) -> Participant? {
        guard let id = id else {
            return nil
        }
        
        if let participant = participants[id] {
            return participant
        } else if let groupId = groupParticipantIds[id], let groupIdParticipant = participants[groupId] {
            return groupIdParticipant
        } else {
            return nil
        }
    }
}
