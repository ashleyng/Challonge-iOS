//
//  MatchViewModel.swift
//  Challonge
//
//  Created by Ashley Ng on 2/24/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking


struct MatchViewModel {
    
    enum CellState {
        case noScore
        case hasScore
    }
    
    enum Player {
        case playerOne
        case playerTwo
    }
    
    private let match: Match
    private var player1: Participant? = nil
    private var player2: Participant? = nil
    private var preReqsPlayer1String: String?
    private var preReqsPlayer2String: String?
    private(set) var state: CellState = .noScore
    
    init(match: Match, mappedMatches: [Int: Match], participants: [Int: Participant]) {
        self.match = match
        if let player1Id = match.player1Id {
            self.player1 = participants[player1Id]
        }
        
        if let player2Id = match.player2Id {
            self.player2 = participants[player2Id]
        }
        preReqsPlayer1String = preReqMatchString(preReq: match.preReqInfo,
                                                 match: mappedMatches.optionalKeyedValueOrDefaultValue(key: match.preReqInfo.player2MatchId),
                                                 player: .playerOne)
        preReqsPlayer2String = preReqMatchString(preReq: match.preReqInfo,
                                                 match: mappedMatches.optionalKeyedValueOrDefaultValue(key: match.preReqInfo.player2MatchId),
                                                 player: .playerTwo)
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
    
    private func preReqMatchString(preReq: Match.PreReqInformation, match: Match?, player: Player) -> String? {
        guard let matchString = match?.suggestedPlayOrder else {
            return nil
        }
        let isLoser: Bool = {
            switch player {
                case .playerOne: return preReq.player1MatchIsLoser
                case .playerTwo: return preReq.player2MatchIsLoser
            }
        }()
        let playerString = isLoserMatchString(isLoser: isLoser)
        return playerString.appending("\(matchString)")
    }
    
    private func isLoserMatchString(isLoser: Bool) -> String {
        return isLoser ? "Loser from Match " : "Winner from Match "
    }
}
