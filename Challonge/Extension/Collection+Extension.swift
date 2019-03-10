//
//  Collection+Extension.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key: Element] {
        var dict = [Key: Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension Dictionary {
    func keyedValueOrDefault(key: Key?) -> Value? {
        guard let key = key else {
            return nil
        }
        return self[key]
    }
}
