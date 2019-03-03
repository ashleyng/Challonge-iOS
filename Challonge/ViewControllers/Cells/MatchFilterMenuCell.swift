//
//  MatchFilterMenuCell.swift
//  Challonge
//
//  Created by Ashley Ng on 3/3/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MatchFilterMenuCell: UICollectionViewCell {
    private let label = UILabel()
    var title: String = "" {
        didSet {
            guard title != oldValue else {
                return
            }
            label.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        addSubview(label)
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.top.bottom.right.left.equalTo(self)
        }
    }
}
