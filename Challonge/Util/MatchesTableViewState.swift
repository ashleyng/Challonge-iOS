//
//  MatchesTableViewState.swift
//  Challonge
//
//  Created by Ashley Ng on 3/8/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking

enum MatchesTableViewState {
    case loading
    case populated([Match], [Int: Participant], [Int: Int], MatchFilterMenu.MenuState?)
    case empty
    case error(Error)
    
    var allMatches: [Match] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let matches, _, _, _):
            return matches
        }
    }
    
    var filteredMatches: [Match] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let matches, _, _, let filter):
            return matches.filter { match in
                switch filter {
                case .all?:
                    return true
                case .winner?:
                    return match.round > 0
                case .loser?:
                    return match.round < 0
                default: return true
                }
            }
        }
    }
    
    var currentParticipants: [Int: Participant] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(_, let participants, _, _):
            return participants
        }
    }
    
    var groupParticipantIds: [Int: Int] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(_, _, let participants, _):
            return participants
        }
    }
}
