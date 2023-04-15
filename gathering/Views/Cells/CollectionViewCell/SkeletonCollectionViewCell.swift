//
//  SkeletonCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-15.
//

import UIKit

import IGListKit

class SkeletonCollectionViewCell: UICollectionViewCell, ListBindable {
    
    let identifier = "SkeletonCollectionViewCell"
    
    private let eventImageView:UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .secondarySystemBackground 
        return view
    }()
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let dateLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    private let locationLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [eventImageView, titleLabel,dateLabel,locationLabel].forEach({addSubview($0)})
        backgroundColor = .systemBackground
        
        let leftPadding:CGFloat = 13
        let rightPadding:CGFloat = 13
        
        let eventImageSize:CGFloat = width/4.3+5
        let eventImageHeight:CGFloat = eventImageSize*1.3
        eventImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil,
                              padding: .init(top: 15, left: leftPadding, bottom: 15, right: 0),
                              size: .init(width: eventImageSize, height: eventImageHeight))
        
        
        titleLabel.anchor(top: eventImageView.topAnchor, leading: eventImageView.trailingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 150, height: 30))
        
        dateLabel.anchor(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 100, height: 30))
        
        locationLabel.anchor(top: dateLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 100, height: 30))
         
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? SkeletonViewModel else {return}
        
        
    }
    
    
}
