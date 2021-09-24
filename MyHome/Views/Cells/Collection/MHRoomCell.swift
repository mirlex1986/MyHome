//
//  MHRoomCell.swift
//  MyHome
//
//  Created by Aleksey Mironov on 21.09.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import HomeKit

class MHRoomCell: RxCollectionViewCell {
    private var mainView: UIView!
    private var roomImage: UIImageView!
    private var textStack: UIStackView!
    private var roomLabel: UILabel!
    private var roomAccessoriesLabel: UILabel!
    var button: UIButton!
    
    // MARK: - Lifecycle
    override func initialSetup() {
        super.initialSetup()
        
        makeUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    func configure(with room: HMRoom) {
        roomLabel.text = room.name
        room.accessories.forEach { accessory in
            accessory.services.forEach { service in
                if service.isPrimaryService || service.isUserInteractive {
                    roomAccessoriesLabel.text?.append("\(service.name) ")
                }
            }
        }
        
        
    }
}

extension MHRoomCell {
    private func makeUI() {
        backgroundColor = .clear
        
        mainView = UIView()
        mainView.layer.borderWidth = 0.3
        mainView.layer.borderColor = CGColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button = UIButton()
        button.setImage(Images.rightSide, for: .normal)
        mainView.addSubview(button)
        button.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview().inset(15)
            $0.size.equalTo(20)
        }
        
        roomImage = UIImageView()
        roomImage.image = UIImage(systemName: "house")
        roomImage.tintColor = .darkGray
        roomImage.contentMode = .scaleAspectFill
        roomImage.clipsToBounds = true
        mainView.addSubview(roomImage)
        roomImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(8)
            $0.size.equalTo(40)
        }
        
        textStack = UIStackView()
        mainView.addSubview(textStack)
        textStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(roomImage.snp.right)
            $0.right.equalTo(button.snp.left)
        }
        
        roomLabel = UILabel()
        roomLabel.text = "Room name"
        roomLabel.font = .systemFont(ofSize: 16)
        textStack.addSubview(roomLabel)
        roomLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalToSuperview().inset(5)
        }
        
        roomAccessoriesLabel = UILabel()
        roomAccessoriesLabel.text = ""
        roomAccessoriesLabel.font = .systemFont(ofSize: 13)
        textStack.addSubview(roomAccessoriesLabel)
        roomAccessoriesLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalTo(roomLabel.snp.bottom)
        }
    }
}

extension MHRoomCell {
    static var cellSize: CGSize { CGSize(width: UIScreen.main.bounds.width, height: 50) }
}
