//
//  UserEventCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-07.
//

import UIKit

class UserEventCell: UICollectionViewCell {
    
    private let eventImageView:UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 5
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
        
    }()
    
    
    let gradientLayer:CAGradientLayer = {
        let view = CAGradientLayer()
        view.colors = [UIColor.mainColor.withAlphaComponent(0.5).cgColor, UIColor.darkMainColor.withAlphaComponent(0.5).cgColor]
        view.locations = [0.0, 1.0]
        return view
    }()
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        view.font = .helveticaBold(ofSize: 24)
        return view
    }()
    private let dateLabel:UILabel = {
        let view = UILabel()
        view.font = .helvetica(ofSize: 14)
        view.textColor  = .secondaryLabel
        return view
    }()
    
    
    private let locationLabel:UILabel = {
        let view = UILabel()
        view.font = .helvetica(ofSize: 14)
        view.textColor  = .secondaryLabel
        return view
    }()
    
    
    private let emojiLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 40)
        view.textAlignment = .center
        return view
    }()
    
    var userEvent:UserEvent? {
        didSet {
            guard let model = userEvent?.toViewModel() else {return}
            titleLabel.text = model.title
            
            dateLabel.text = model.date
            
            locationLabel.text = model.location
            
            if let urlString = model.urlString {
                eventImageView.sd_setImage(with: .init(string: urlString))
                gradientLayer.isHidden = true
            }else {
                emojiLabel.text = model.emojiString
                gradientLayer.isHidden = false
            }
            
            
        }
    }
    
    static let identifier = "UserEventCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [titleLabel,dateLabel,locationLabel,eventImageView].forEach({addSubview($0)})
        
        backgroundColor = .systemBackground
        
        let imageSize:CGFloat = width / 4
        
        eventImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil,padding: .init(top: 5, left: 20, bottom: 5, right: 5), size: .init(width: imageSize, height: imageSize*1.2))
        
        titleLabel.anchor(top: eventImageView.topAnchor, leading: dateLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        
        dateLabel.anchor(top: titleLabel.bottomAnchor, leading: eventImageView.trailingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 10, left: 5, bottom: 0, right: 0))
        locationLabel.anchor(top: dateLabel.bottomAnchor, leading: dateLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = eventImageView.bounds
        emojiLabel.frame = eventImageView.bounds
        eventImageView.layer.addSublayer(gradientLayer)
        eventImageView.addSubview(emojiLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImageView.image = nil
        emojiLabel.text = nil
        
        
    }
    
}
