//
//  Match+Extension.swift
//  Challonge
//
//  Created by Ashley Ng on 2/2/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking

extension Match {
    func score(for participantId: Participant.Id) -> String? {
        for id in participantId.all {
            if id == player1Id {
                return playerOneScore
            }
            
            if id == player2Id {
                return playerTwoScore
            }
        }
        return nil
    }
    
    func vote(for participantId: Participant.Id) -> Int? {
        for id in participantId.all {
            if id == player1Id {
                return player1Votes
            }
            
            if id == player2Id {
                return player2Votes
            }
        }
        return nil
    }
}
