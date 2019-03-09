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
    
    enum CellState {
        case noScore
        case hasScore
    }
    
    private let match: Match
    private let player1: Participant?
    private let player2: Participant?
    private(set) var state: CellState = .noScore
    
    init(match: Match, participants: [Int: Participant], groupParticipantIds: [Int: Int]) {
        self.match = match
        self.player1 = MatchTableViewCellViewModel.getPlayer(with: match.player1Id, participants: participants, groupParticipantIds: groupParticipantIds)
        self.player2 = MatchTableViewCellViewModel.getPlayer(with: match.player2Id, participants: participants, groupParticipantIds: groupParticipantIds)
        state = match.state == .complete ? CellState.hasScore : CellState.noScore
    }
    
    func matchLabel() -> String {
        if let matchNumber = match.suggestedPlayOrder {
            return "Match \(matchNumber)"
        }
        return "Unknown Match"
    }
    
    func matchStatus() -> String {
        return match.state.rawValue
    }
    
    func playerOneName() -> String {
        return player1?.name ?? "Unknown Player"
    }
    
    func playerTwoName() -> String {
        return player2?.name ?? "Unknown Player"
    }
    
    func playerOneStatus() -> String {
        switch match.state {
        case .complete:
            guard let score = match.playerOneScore else {
                fallthrough
            }
            return "\(score)"
        case .open, .pending:
            return match.state.rawValue
        }
    }
    
    // TODO: Fix duplicate code
    func playerTwoStatus() -> String {
        switch match.state {
        case .complete:
            guard let score = match.playerTwoScore else {
                fallthrough
            }
            return "\(score)"
        case .open, .pending:
            return match.state.rawValue
        }
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
