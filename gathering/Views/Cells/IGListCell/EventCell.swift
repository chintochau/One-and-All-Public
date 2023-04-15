//
//  EventIGListCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-20.
//

import UIKit
import IGListKit



class EventCell: BasicEventCollectionViewCell {
    
    static let identifier = "EventCellIdentifier"
    
    private let nameLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let stackView:UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalCentering
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [dateLabel,locationLabel].forEach({stackView.addArrangedSubview($0)})
        
        
        
        let emojiSize:CGFloat = BasicEventCollectionViewCell.generalIconSize
        let padding:CGFloat = 10
        
        addSubview(stackView)
        
        
        
        profileImageview.anchor(
            top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,
            padding: .init(top: 5, left: 10, bottom: 0, right: 0),
            size: CGSize(width: emojiSize, height: emojiSize))
        profileImageview.layer.cornerRadius = emojiSize/2
        
        profileTitleLabel.anchor(
            top: profileImageview.topAnchor, leading: profileImageview.trailingAnchor, bottom: profileImageview.bottomAnchor, trailing: nil,
            padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        
        stackView.anchor(top: profileImageview.bottomAnchor, leading: leadingAnchor, bottom: titleLabel.topAnchor, trailing: trailingAnchor)
        
        titleLabel.anchor(
            top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,
            padding: .init(top: 0, left: padding, bottom: 0, right: padding))
        
        
        introLabel.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: padding, bottom: padding, right: padding))
        
        
        // MARK: - Gender separated
        
        let imageSize:CGFloat = BasicEventCollectionViewCell.iconSize
        maleIconImageView.anchor(top: profileImageview.topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 5),size: CGSize(width: imageSize, height: imageSize))
        
        femaleIconImageView.anchor(top: maleIconImageView.bottomAnchor, leading: maleIconImageView.leadingAnchor, bottom: nil, trailing: nil,size: CGSize(width: imageSize, height: imageSize))
        
        
        maleNumber.sizeToFit()
        maleNumber.anchor(top: maleIconImageView.topAnchor, leading: nil, bottom: maleIconImageView.bottomAnchor, trailing: maleIconImageView.leadingAnchor)
        
        femaleNumber.sizeToFit()
        femaleNumber.anchor(top: femaleIconImageView.topAnchor, leading: nil, bottom: femaleIconImageView.bottomAnchor, trailing: femaleIconImageView.leadingAnchor)
        
        // MARK: - all gender
        
        let totalImageSize:CGFloat = BasicEventCollectionViewCell.generalIconSize/1.5
        totalIconImageView.anchor(top: profileImageview.topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 10),size: CGSize(width: totalImageSize, height: totalImageSize))
        
        totalNumber.sizeToFit()
        totalNumber.anchor(top: totalIconImageView.topAnchor, leading: nil, bottom: totalIconImageView.bottomAnchor, trailing: totalIconImageView.leadingAnchor
                           ,padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        
        
        backgroundShade.anchor(top: titleLabel.topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
    }
    
    override func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? EventCellViewModel else { return }
        // Update the cell with the event information
        if let profileImage = vm.organiser?.profileUrlString {
            profileImageview.sd_setImage(with: URL(string: profileImage))
        }
        
        
        // Sub info label
        dateLabel.attributedText = createAttributedText(with: vm.dateString, imageName: "calendar")
        locationLabel.attributedText = createAttributedText(with: vm.location, imageName: "mappin.and.ellipse")
        
        eventImageView.sd_setImage(with: URL(string: vm.imageUrlString ?? ""))
        titleLabel.text = vm.title
        emojiIconLabel.text = vm.emojiString
        introLabel.text = vm.intro
        profileTitleLabel.text = vm.organiser?.name
        
        if vm.headcount.isGenderSpecific {
            [totalNumber,totalIconImageView
            ].forEach({$0.isHidden = true})
            
            let maleMax = vm.headcount.mMax
            let femaleMax = vm.headcount.fMax
            
            if maleMax == 0 {
                maleNumber.text = "\(vm.peopleCount.male)"
            }else {
                maleNumber.text = "\(vm.peopleCount.male) / \(maleMax)"
            }
            
            if femaleMax == 0 {
                femaleNumber.text = "\(vm.peopleCount.female)"
            }else {
                femaleNumber.text = "\(vm.peopleCount.female) / \(femaleMax)"
            }
            
            
        }else {
            [maleNumber,femaleNumber,
             maleIconImageView,femaleIconImageView
            ].forEach({$0.isHidden = true})
            
            totalNumber.text = vm.totalString
        }
         
    }
    
    
    
}




class PeopleCell: UICollectionViewCell, ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let event = viewModel as? EventCellViewModel else { return }
        // Update the cell with the event information
    }
}

class PlaceCell: UICollectionViewCell, ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let event = viewModel as? EventCellViewModel else { return }
        // Update the cell with the event information
    }
}
