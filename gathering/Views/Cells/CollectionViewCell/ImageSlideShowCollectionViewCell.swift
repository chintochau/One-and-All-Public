//
//  ImageSlideShowCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-13.
//

import UIKit
import ImageSlideshow
import SDWebImage

protocol ImageSlideShowCollectionViewCellDelegate:AnyObject {
    func ImageSlideShowCollectionViewCellDidTapImage(_ cell:ImageSlideShowCollectionViewCell)
}

class ImageSlideShowCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImageSlideShowCollectionViewCell"
    
    weak var delegate: ImageSlideShowCollectionViewCellDelegate?
    
    let slideshow = ImageSlideshow()
    
    var urlStrings:[String] = [] {
        didSet{
            
            let imageInputs = urlStrings.compactMap({
                SDWebImageSource(urlString: $0)
            })
            slideshow.setImageInputs(imageInputs)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlideshow()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSlideshow() {
        addSubview(slideshow)
        slideshow.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(gestureRecognizer)
        slideshow.preload = .fixed(offset: 1)
        slideshow.circular = false
        
        slideshow.zoomEnabled = true
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
    }
    
    @objc func didTap() {
        delegate?.ImageSlideShowCollectionViewCellDidTapImage(self)
    }
    
}

