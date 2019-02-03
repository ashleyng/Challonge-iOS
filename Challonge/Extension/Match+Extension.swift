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
            if let value = scores?[id] {
                return value
            }
        }
        return nil
    }
}
