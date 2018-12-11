//
//  Button+Extension.swift
//  Challonge
//
//  Created by Ashley Ng on 12/10/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func roundEdges(withRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}
