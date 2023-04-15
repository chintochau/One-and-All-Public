//
//  EventLargeCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import UIKit

final class LargeEventCollectionViewCell: BasicEventCollectionViewCell {
    static let identifier = "EventLargeCollectionViewCell"
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .secondarySystemBackground
        eventImageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        dateLabel.frame = CGRect(x: 7, y: eventImageView.bottom+10, width: dateLabel.width, height: dateLabel.height)
        titleLabel.frame = CGRect(x: 7, y: dateLabel.bottom+5, width: titleLabel.width, height: titleLabel.height)
        locationLabel.frame = CGRect(x: 7, y: titleLabel.bottom+10, width: locationLabel.width, height: locationLabel.height)
        
        
        
        priceLabel.sizeToFit()
        priceLabel.frame = CGRect(x: width-priceLabel.width-10, y: height-priceLabel.height-10, width: priceLabel.width, height: priceLabel.height)
        
        let buttonSize:CGFloat = 30
        shareButton.frame = CGRect(x: width-buttonSize-5, y: priceLabel.top-buttonSize-5, width: buttonSize, height: buttonSize)
        likeButton.frame = CGRect(x: shareButton.left-buttonSize, y: priceLabel.top-buttonSize-5, width: buttonSize, height: buttonSize)
        
        
        
        let imageSize:CGFloat = 20
        maleIconImageView.frame = CGRect(x: 7, y: height-2*buttonSize, width: imageSize, height: imageSize)
        femaleIconImageView.frame = CGRect(x: 7, y: height-buttonSize-5, width: imageSize, height: imageSize)
        maleNumber.sizeToFit()
        maleNumber.frame = CGRect(x: maleIconImageView.right+5, y: maleIconImageView.top, width: maleNumber.width, height: maleNumber.height)
        femaleNumber.sizeToFit()
        femaleNumber.frame = CGRect(x: femaleIconImageView.right+5, y: femaleIconImageView.top, width: femaleNumber.width, height: femaleNumber.height)
        
        let totalImageSize:CGFloat = 30
        totalIconImageView.frame = CGRect(x: 7, y: height-totalImageSize-7, width: totalImageSize, height: totalImageSize)
        totalNumber.sizeToFit()
        totalNumber.frame = CGRect(
            x: totalIconImageView.right+5, y: totalIconImageView.top, width: totalNumber.width, height:totalImageSize)
        
        
    }
    
    
}

