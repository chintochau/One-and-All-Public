//
//  EventDetailCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-19.
//

import UIKit

enum EventInfoCollectionViewCellViewModel {
    case title(title:String)
    case info (title:String,subTitle:String, type:InfoCardType)
    case extraInfo (title:String, info:String)
    case owner(name:User?)
}

enum InfoCardType {
    case time
    case location
    case refundPolicy
}

protocol EventInfoCollectionViewCellDelegate:AnyObject {
    func EventInfoCollectionViewCellDidTapShowMore(_ cell:EventInfoCollectionViewCell)
}

class EventInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "EventDetailCollectionViewCell"
    
    weak var delegate: EventInfoCollectionViewCellDelegate?
    private var cellType: EventInfoCollectionViewCellViewModel?
    
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 3
        return label
    }()
    
    private let infoTitleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15,weight: .bold)
        return label
    }()
    
    private let subTitleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.font = .systemFont(ofSize: 16,weight: .light)
        return label
    }()
    
    private let icon:UIImageView = {
        let view = UIImageView()
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let button:UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configureCell(with type:EventInfoCollectionViewCellViewModel){
        
        switch type {
        case .title(let title):
            titleLabel.text = title
            addSubview(titleLabel)
            titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 10, left: 0, bottom: 10, right: 0))
            
        case .info(title: let title, subTitle: let subTitle, type: let type):
            
            infoTitleLabel.text = title
            subTitleLabel.text = subTitle
            
            var iconString:String
            switch type {
            case .time:
                iconString = "calendar"
            case .location:
                iconString = "mappin.and.ellipse"
            case .refundPolicy:
                iconString = "questionmark.circle"
            }
            icon.image = UIImage(systemName: iconString)
            
            addSubview(infoTitleLabel)
            addSubview(subTitleLabel)
            addSubview(button)
            addSubview(icon)
            
            let iconSize = 25
            icon.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,size: CGSize(width: iconSize, height: iconSize))
            infoTitleLabel.anchor(top: icon.topAnchor, leading: icon.trailingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 5, bottom: 0, right: 0))
            subTitleLabel.anchor(top: infoTitleLabel.bottomAnchor, leading: infoTitleLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor)
            button.anchor(top: subTitleLabel.bottomAnchor, leading: infoTitleLabel.leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
            let buttonConstraint = button.heightAnchor.constraint(equalToConstant: 0)
            buttonConstraint.isActive = true
//            buttonConstraint.isActive = false
            
        case .extraInfo(title: let title, info: let info):
            infoTitleLabel.text = title
            subTitleLabel.text = info
            button.setTitle("Show More", for: .normal)
            button.addTarget(self, action: #selector(didTapShowMore), for: .touchUpInside)
            
            addSubview(infoTitleLabel)
            addSubview(subTitleLabel)
            addSubview(button)
            subTitleLabel.sizeToFit()
            subTitleLabel.frame = CGRect(x: 0, y: 0, width: subTitleLabel.width, height: subTitleLabel.height)
            
            if subTitleLabel.countLines() > 4 {
                infoTitleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
                subTitleLabel.anchor(top: infoTitleLabel.bottomAnchor, leading: infoTitleLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor)
                button.anchor(top: subTitleLabel.bottomAnchor, leading: infoTitleLabel.leadingAnchor, bottom: bottomAnchor, trailing: nil)
            }else {
                button.isHidden = true
                infoTitleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
                subTitleLabel.anchor(top: infoTitleLabel.bottomAnchor, leading: infoTitleLabel.leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
            }
            
            
        case .owner:
            // pleaser refer to EventOwnerCollectionViewCell
            fatalError("Should never execute")
            break
        }
        
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        infoTitleLabel.text = nil
        subTitleLabel.text = nil
        button.setTitle(nil, for: .normal)
        icon.image = nil
        
        
        [titleLabel,
        infoTitleLabel,
        subTitleLabel,
        button,
         icon].forEach({ $0.removeFromSuperview()})
        
    }
    
    
    @objc func didTapShowMore () {
        
        subTitleLabel.numberOfLines = 0
        button.isHidden = true
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.layoutIfNeeded()
            self.delegate?.EventInfoCollectionViewCellDidTapShowMore(self)
        }
    }
    
}

