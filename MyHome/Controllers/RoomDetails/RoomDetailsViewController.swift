//
//  RoomDetailsViewController.swift
//  MyHome
//
//  Created by Aleksey Mironov on 24.09.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import HomeKit

class RoomDetailsViewController: UIViewController {
    // MARK: - UI
    private var collectionView: UICollectionView!
    private var label: UILabel!
    
    // MARK: - Properties
    typealias Item = RoomDetailsViewModel.ItemModel
    typealias Section = RoomDetailsViewModel.SectionModel
    
    let homeManager = HMHomeManager()
    var viewModel: RoomDetailsViewModel!
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        homeManager.delegate = self
        makeUI()
        prepare()
        subscribe()
    }
    
    // MARK: - Functions
    private func prepare() {
        dataSource = generateDataSource()
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: viewModel.disposeBag)
    }
    
    private func subscribe() {
        viewModel.sections.asObservable()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
    }
    
    private func generateDataSource() -> RxCollectionViewSectionedAnimatedDataSource<Section> {
        return RxCollectionViewSectionedAnimatedDataSource<Section>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .fade,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .fade),
            configureCell: { dataSource, collectionView, indexPath, _ in
                let item: Item = dataSource[indexPath]
                switch item {
                case .accessory(let service):
                    return self.accessoryCell(indexPath: indexPath, service: service)
//                case .button:
//                    return self.buttonCell(indexPath: indexPath)
//                case .room(let room):
//                    return self.roomCell(indexPath: indexPath, room: room)
                }
            },
            configureSupplementaryView: { _, _, _, _ in
                return UICollectionReusableView()
            })
    }
    
    // MARK: - Cells
//    private func buttonCell(indexPath: IndexPath) -> MHCollectionViewCell {
//        let cell: MHButtonCell = collectionView.cell(indexPath: indexPath)
//        cell.configure(text: "text")
//        
//        return cell
//    }
//    
//    private func roomCell(indexPath: IndexPath, room: HMRoom) -> MHCollectionViewCell {
//        let cell: MHRoomCell = collectionView.cell(indexPath: indexPath)
//        cell.configure(with: room)
//        
//        return cell
//    }
    private func accessoryCell(indexPath: IndexPath, service: HMService) -> MHCollectionViewCell {
        let cell: MHAccessoryCell = collectionView.cell(indexPath: indexPath)
        cell.configure(with: service)
        
        cell.accessoryStateSwich.rx.value
            .subscribe(onNext: { value in
                
                service.characteristics.forEach { characteristic in
                    if characteristic.characteristicType == HMCharacteristicTypePowerState {
                        characteristic.writeValue(value) { error in
                            print(error?.localizedDescription)
                        }
                    }
                }
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RoomDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .accessory:
            return MHAccessoryCell.cellSize
//        case .button:
//            return MHButtonCell.cellSize
//        case .room:
//            return MHRoomCell.cellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - HMHomeManagerDelegate
//extension RoomDetailsViewController: HMHomeManagerDelegate {
//    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
//        guard let primaryHome = manager.homes.first else { return }
//
//        viewModel.primaryHome.accept(primaryHome)
//    }
//}

extension RoomDetailsViewController {
    func makeUI() {
        view.backgroundColor = .white
        
        let navBar = UINavigationBar()
        let navigationItem = UINavigationItem(title: viewModel.room.value?.name ?? "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: #selector(close))
        navigationItem.hidesBackButton = false
        navBar.setItems([navigationItem], animated: true)
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
        
        // COLLECTION VIEW
        collectionView = makeCollectionView()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navBar.snp.bottom).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
    }
    
    private func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = MHCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }
    
    @objc func close(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}

