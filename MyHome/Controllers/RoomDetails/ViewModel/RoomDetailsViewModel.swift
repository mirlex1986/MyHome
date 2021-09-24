//
//  RoomDetailsViewModel.swift
//  MyHome
//
//  Created by Aleksey Mironov on 24.09.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import HomeKit

final class RoomDetailsViewModel {
    // MARK: - Properties
    var room = BehaviorRelay<HMRoom?>.init(value: nil)
    var accessories = BehaviorRelay<[HMAccessory]?>.init(value: [])
    
    let disposeBag = DisposeBag()
    let sections = BehaviorRelay<[SectionModel]>.init(value: [])
    
    init(room: HMRoom) {
        self.room.accept(room)
        
        subscribe()
    }
    
    // MARK: - Functions
    private func subscribe() {
        room
            .subscribe(onNext: { [weak self] room in
                guard let self = self, room != nil else { return }
                
                self.accessories.accept(room?.accessories)
            })
            .disposed(by: disposeBag)
        
        accessories
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.configureSections()
            })
            .disposed(by: disposeBag)
    }
    
    func configureSections() {
        var items: [ItemModel] = []
        guard let accessories = accessories.value else { return }
        
        accessories.forEach { accessory in
            accessory.services.forEach { service in
                if service.isUserInteractive || service.isPrimaryService {
                items.append(.accessory(service: service))
                }
            }
        }
        
        sections.accept([.mainSection(items: items)])
    }
}

// MARK: - Data source
extension RoomDetailsViewModel {
    enum SectionModel {
        case mainSection(items: [ItemModel])
    }
    
    enum ItemModel {
        case accessory(service: HMService)

        var id: String {
            switch self {
            case .accessory(let service):
                return "accessory \(service.characteristics.map({ $0.value }))"
            }
        }
    }
}

extension RoomDetailsViewModel.SectionModel: AnimatableSectionModelType {
    typealias Item = RoomDetailsViewModel.ItemModel
    
    var identity: String {
        return "main_section"
    }
    
    var items: [RoomDetailsViewModel.ItemModel] {
        switch self {
        case .mainSection(let items):
            return items.map { $0 }
        }
    }
    
    init(original: RoomDetailsViewModel.SectionModel, items: [RoomDetailsViewModel.ItemModel]) {
        switch original {
        case .mainSection:
            self = .mainSection(items: items)
        }
    }
}

extension RoomDetailsViewModel.ItemModel: RxDataSources.IdentifiableType, Equatable {
    static func == (lhs: RoomDetailsViewModel.ItemModel, rhs: RoomDetailsViewModel.ItemModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
    var identity: String {
        return id
    }
}
