//
//  UserMediumCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-15.
//

import UIKit

class UserMediumCollectionViewCell: UICollectionViewCell {
    
    private let profileImage:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .secondaryLabel.withAlphaComponent(0.5)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        
        return view
    }()
    
    private let nameLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18)
        view.textAlignment = .center
        return view
    }()
    
    private let interestsLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.textAlignment = .center
        return view
        
    }()
    
    var user:User? {
        didSet{
            guard  let user =  user else {return}
            if let imageUrlString = user.profileUrlString {
                profileImage.sd_setImage(with: URL(string: imageUrlString))
                profileImage.contentMode = .scaleAspectFill
            }
            nameLabel.text = user.name ?? user.username
            if let interests = user.interests {
                
                for index in 0..<interests.count {
                    
                    if index == 0{
                        interestsLabel.text = interests[index]
                    }else {
                        interestsLabel.text! += "·\(interests[index])"
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    static let identifier = "UserMediumCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [profileImage,nameLabel,interestsLabel].forEach({addSubview($0)})
        backgroundColor = .secondarySystemBackground
        
        let imageSize:CGFloat = 80
        
        profileImage.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: nil,padding: .init(top: 30, left: 0, bottom: 0, right: 0),size: .init(width: imageSize, height: imageSize))
        profileImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImage.layer.cornerRadius = imageSize/2
        
        nameLabel.anchor(top: profileImage.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 5, left: 5, bottom: 20, right: 5))
        
        interestsLabel.anchor(top: nameLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 5, left: 0, bottom: 30, right: 0))
        
        
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = .personIcon
        profileImage.contentMode = .scaleAspectFit
        nameLabel.text = nil
    }
    
    
}
