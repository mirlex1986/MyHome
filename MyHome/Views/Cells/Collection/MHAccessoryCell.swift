//
//  MHAccessoryCell.swift
//  MyHome
//
//  Created by Aleksey Mironov on 24.09.2021.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa
import HomeKit

class MHAccessoryCell: RxCollectionViewCell {
    private var mainView: UIView!
    private var accessoryImage: UIImageView!
    private var accessoryNameLabel: UILabel!
    private var accessoryValueLabel: UILabel!
    var accessoryStateSwich: UISwitch!
    
    // MARK: - Lifecycle
    override func initialSetup() {
        super.initialSetup()
        
        makeUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        accessoryValueLabel.isHidden = true
        accessoryStateSwich.isHidden = true
        
        disposeBag = DisposeBag()
    }
    
    func configure(with service: HMService) {
        if service.isUserInteractive || service.isPrimaryService {
            accessoryNameLabel.text = service.name
            
            if service.serviceType == HMServiceTypeOutlet || service.serviceType == HMServiceTypeSwitch {
                service.characteristics.forEach { characteristic in
                    if characteristic.characteristicType == HMCharacteristicTypePowerState,
                       let value = characteristic.value as? Bool {
                        accessoryImage.image = UIImage(systemName: "power")
                        accessoryStateSwich.isOn = value
                        accessoryStateSwich.isHidden = false
                    }
                }
            }
            
            if service.serviceType == HMServiceTypeLightbulb {
                service.characteristics.forEach { characteristic in
                    if characteristic.characteristicType == HMCharacteristicTypePowerState,
                        let value = characteristic.value as? Bool {
                        accessoryImage.image = value ? UIImage(systemName: "lightbulb.fill") : UIImage(systemName: "lightbulb")
                        accessoryStateSwich.isOn = value
                        accessoryStateSwich.isHidden = false
                    }
                }
            }
            
            service.characteristics.forEach { characteristic in
                if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity,
                   let humidityValue = (characteristic.value as? NSNumber)?.floatValue {
                    accessoryValueLabel.text = "\(String(format: "%.f", humidityValue))%"
                    accessoryImage.image = UIImage(systemName: "humidity")
                    accessoryValueLabel.isHidden = false
                }

                if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature,
                   let tempValue = (characteristic.value as? NSNumber)?.floatValue {
                    accessoryValueLabel.text = "\(String(format: "%.1f", tempValue))"
                    accessoryImage.image = UIImage(systemName: "thermometer")
                    accessoryImage.contentMode = .scaleAspectFit
                    accessoryValueLabel.isHidden = false
                }
            }
        }
    }
}

extension MHAccessoryCell {
    private func makeUI() {
        backgroundColor = .clear
        
        mainView = UIView()
        mainView.layer.borderWidth = 0.3
        mainView.layer.borderColor = CGColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        accessoryImage = UIImageView()
        accessoryImage.image = UIImage(systemName: "house")
        accessoryImage.tintColor = .darkGray
        accessoryImage.contentMode = .scaleAspectFill
        accessoryImage.clipsToBounds = true
        mainView.addSubview(accessoryImage)
        accessoryImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(8)
            $0.size.equalTo(30)
        }
        
        accessoryNameLabel = UILabel()
        accessoryNameLabel.text = "Room name"
        accessoryNameLabel.font = .systemFont(ofSize: 16)
        mainView.addSubview(accessoryNameLabel)
        accessoryNameLabel.snp.makeConstraints {
            $0.left.equalTo(accessoryImage.snp.right).offset(4)
            $0.centerY.equalToSuperview()
        }
        
        accessoryValueLabel = UILabel()
        accessoryValueLabel.isHidden = true
        accessoryValueLabel.text = ""
        accessoryValueLabel.font = .systemFont(ofSize: 20)
        mainView.addSubview(accessoryValueLabel)
        accessoryValueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(10)
        }
        
        accessoryStateSwich = UISwitch()
        accessoryStateSwich.isHidden = true
        mainView.addSubview(accessoryStateSwich)
        accessoryStateSwich.snp.makeConstraints {
            $0.right.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
    }
}

extension MHAccessoryCell {
    static var cellSize: CGSize { CGSize(width: UIScreen.main.bounds.width, height: 50) }
}
