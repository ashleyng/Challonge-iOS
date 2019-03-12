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
    private let selectedView = UIView()
    var title: String = "" {
        didSet {
            guard title != oldValue else {
                return
            }
            label.text = title
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else {
                return
            }
            selectedView.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
        setupSelectedView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        addSubview(label)
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview()
        }
    }
    
    private func setupSelectedView() {
        selectedView.backgroundColor = UIColor(red: 237/255, green: 31/255, blue: 22/255, alpha: 1)
        selectedView.isHidden = true
        selectedView.layer.cornerRadius = 4.0
        selectedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(selectedView)
        selectedView.snp.makeConstraints { make in
            make.height.equalTo(4)
            make.width.equalTo(88)
            make.centerX.bottom.equalToSuperview()
        }
    }
}
