//
//  HomeViewController.swift
//  MyHome
//
//  Created by Aleksey Mironov on 21.09.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import HomeKit

class HomeViewController: UIViewController {
    // MARK: - UI
    private var segmentSwich: UISegmentedControl!
    private var collectionView: UICollectionView!
    private var label: UILabel!
    
    // MARK: - Properties
    typealias Item = HomeViewModel.ItemModel
    typealias Section = HomeViewModel.SectionModel
    
    let homeManager = HMHomeManager()
    var viewModel = HomeViewModel()
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeManager.delegate = self
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
        
//        collectionView.rx.itemSelected
//            .subscribe(onNext: { [weak self] _ in
//                guard let self = self else { return }
//                
//                
//            })
//            .disposed(by: viewModel.disposeBag)
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
                case .button:
                    return self.buttonCell(indexPath: indexPath)
                case .room(let room):
                    return self.roomCell(indexPath: indexPath, room: room)
                }
            },
            configureSupplementaryView: { _, _, _, _ in
                return UICollectionReusableView()
            })
    }
    
    // MARK: - Cells
    private func buttonCell(indexPath: IndexPath) -> MHCollectionViewCell {
        let cell: MHButtonCell = collectionView.cell(indexPath: indexPath)
        cell.configure(text: "text")
        
        return cell
    }
    
    private func roomCell(indexPath: IndexPath, room: HMRoom) -> MHCollectionViewCell {
        let cell: MHRoomCell = collectionView.cell(indexPath: indexPath)
        cell.configure(with: room)
        
        cell.button.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let vc = RoomDetailsViewController()
                    vc.viewModel = RoomDetailsViewModel(room: room)
                
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .button:
            return MHButtonCell.cellSize
        case .room:
            return MHRoomCell.cellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - HMHomeManagerDelegate
extension HomeViewController: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard let primaryHome = manager.homes.first else { return }

        viewModel.primaryHome.accept(primaryHome)
    }
}

extension HomeViewController {
    func makeUI() {
        view.backgroundColor = .white
        
        let navBar = UINavigationBar()
        let navigationItem = UINavigationItem(title: viewModel.primaryHome.value?.name ?? "Дом")
        navBar.setItems([navigationItem], animated: true)
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
        
        segmentSwich = UISegmentedControl(items: [MainViewType.room.rawValue, MainViewType.device.rawValue])
        segmentSwich.backgroundColor = .lightGray
        segmentSwich.selectedSegmentIndex = 0
        view.addSubview(segmentSwich)
        segmentSwich.snp.makeConstraints {
            $0.top.equalTo(navBar.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(40)
        }
        
        // COLLECTION VIEW
        collectionView = makeCollectionView()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(segmentSwich.snp.bottom).offset(20)
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

}
