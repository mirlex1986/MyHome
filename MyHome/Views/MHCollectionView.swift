//
//  MHCollectionView.swift
//  MyHome
//
//  Created by Aleksey Mironov on 21.09.2021.
//

import UIKit

class MHCollectionView: UICollectionView {}

extension MHCollectionView {
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        keyboardDismissMode = .onDrag
        
        register(cellType: MHButtonCell.self)
        register(cellType: MHRoomCell.self)
        register(cellType: MHAccessoryCell.self)
        register(cellType: MHDataTypeCell.self)
    }
}
