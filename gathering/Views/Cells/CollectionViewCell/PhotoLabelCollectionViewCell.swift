//
//  PhotoLabelCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-24.
//

import UIKit

class PhotoLabelCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoLabelCollectionViewCell"
    
    let imageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        view.tintColor = .lightGray
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    private let textLabel:UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.textAlignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(textLabel)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height-20)
        textLabel.frame = CGRect(x: 0, y: imageView.bottom, width: imageView.width, height: 500)
        textLabel.sizeToFit()
        textLabel.frame = CGRect(x: 0, y: imageView.bottom, width: imageView.width, height: textLabel.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withUrlString url:String,text:String){
        imageView.sd_setImage(with: URL(string: url))
        textLabel.text = text
    }
    
    func configure(withImage image:UIImage?,text:String){
        imageView.image = image
        textLabel.text = text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        textLabel.text = nil
    }
}
