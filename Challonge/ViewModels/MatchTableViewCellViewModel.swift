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
    private let preReqsPlayer1String: String?
    private let preReqsPlayer2String: String?
    private(set) var state: CellState = .noScore
    
    init(match: Match, mappedMatches: [Int: Match], participants: [Int: Participant], groupParticipantIds: [Int: Int]) {
        self.match = match
        self.player1 = MatchTableViewCellViewModel.getPlayer(with: match.player1Id, participants: participants, groupParticipantIds: groupParticipantIds)
        self.player2 = MatchTableViewCellViewModel.getPlayer(with: match.player2Id, participants: participants, groupParticipantIds: groupParticipantIds)
        preReqsPlayer1String = MatchTableViewCellViewModel.constructPlayer1PreReqString(mappedMatch: mappedMatches, match: match)
        preReqsPlayer2String = MatchTableViewCellViewModel.constructPlayer2PreReqString(mappedMatch: mappedMatches, match: match)
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
        if let name = player1?.name {
            return name
        } else if let preReqMatch = preReqsPlayer1String {
            return preReqMatch
        }
        return "Unknown Player"
    }
    
    func playerTwoName() -> String {
        if let name = player2?.name {
            return name
        } else if let preReqMatch = preReqsPlayer2String {
            return preReqMatch
        }
        return "Unknown Player"
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
    
    private static func constructPlayer1PreReqString(mappedMatch: [Int: Match], match: Match) -> String? {
        if let player1Match = match.preReqInfo.player1MatchId, let matchString = mappedMatch[player1Match]?.suggestedPlayOrder {
            let player1String = match.preReqInfo.player1MatchIsLoser ? "Loser from Match " : "Winner from Match "
            return player1String.appending(String(matchString))
        }
        return nil
    }
    
    private static func constructPlayer2PreReqString(mappedMatch: [Int: Match], match: Match) -> String? {
        if let player2Match = match.preReqInfo.player2MatchId, let matchString = mappedMatch[player2Match]?.suggestedPlayOrder {
            let player2String = match.preReqInfo.player2MatchIsLoser ? "Loser from Match " : "Winner from Match "
            return player2String.appending(String(matchString))
        }
        return nil
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
