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

protocol MatchFilterMenuDelegate: class {
    func filterDidChange(newFilter: MatchFilterMenu.MenuState)
}

class MatchFilterMenu: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    enum MenuState: Int {
        case all
        case winner
        case loser
        
        var title: String {
            switch self {
            case .all: return "All"
            case .winner: return "Winner"
            case .loser: return "Loser"
            }
        }
    }
    
    private let menuStates = [MenuState.all, MenuState.winner, MenuState.loser]
    
    weak var delegate: MatchFilterMenuDelegate?
    
    private lazy var collectionView: UICollectionView =  {
       let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MatchFilterMenuCell.self, forCellWithReuseIdentifier: MatchFilterMenuCell.identifier)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview()
        }
        //TODO: make this configurable?
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuStates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / CGFloat(menuStates.count), height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = menuStates[indexPath.row]
        delegate?.filterDidChange(newFilter: filter)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatchFilterMenuCell.identifier, for: indexPath) as? MatchFilterMenuCell else {
            return UICollectionViewCell()
        }
        let menuValue = MenuState(rawValue: indexPath.row)
        var title = ""
        // TODO make this better?
        switch menuValue {
        case .all?:
            title = menuValue!.title
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
