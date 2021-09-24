//
//  UICollectionView + Extention.swift
//  MyHome
//
//  Created by Aleksey Mironov on 21.09.2021.
//

import RxSwift
import RxCocoa

extension UICollectionView {
    func cell<T: UICollectionViewCell>(forClass cellClass: T.Type = T.self, indexPath: IndexPath) -> T {
        let className = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as? T else { return T() }
        return cell
    }
    
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: String(describing: cellType))
    }
}
