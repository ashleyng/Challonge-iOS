//
//  MatchFilterMenu.swift
//  Challonge
//
//  Created by Ashley Ng on 3/3/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MatchFilterMenu: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    enum MenuState: Int {
        case winner
        case loser
        
        var title: String {
            switch self {
            case .winner: return "Winner"
            case .loser: return "Loser"
            }
        }
    }
    
    private let CELL_REUSE_ID = "CellId"
    private lazy var collectionView: UICollectionView =  {
       let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MatchFilterMenuCell.self, forCellWithReuseIdentifier: CELL_REUSE_ID)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.right.left.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2 // TODO: currently support winner/loser bracket, need to be able to handle group stages
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected index: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_REUSE_ID, for: indexPath) as? MatchFilterMenuCell else {
            return UICollectionViewCell()
        }
        let menuValue = MenuState(rawValue: indexPath.row)
        var title = ""
        switch menuValue {
        case .winner?:
            title = menuValue!.title
        case .loser?:
            title = menuValue!.title
        default: break
        }
        cell.title = title
        return cell
    }
    
}
