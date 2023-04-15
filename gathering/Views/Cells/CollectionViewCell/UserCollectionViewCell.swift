//
//  UserCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-01.
//

import UIKit
import IGListKit
import SwipeCellKit

class UserCollectionViewCell: UICollectionViewCell,ListBindable {
    
    static let identifier = "UserCollectionViewCell"
    
    private let profileImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.masksToBounds = true
        view.image = UIImage(systemName: "person.crop.circle")
        view.tintColor = .lightGray
        return view
    }()
    
    private let nameLabel:UILabel = {
        let view  = UILabel()
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 18)
        return view
    }()
    private let usernameLabel:UILabel = {
        let view  = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 1
        return view
    }()
    private let valuelabel:UILabel = {
        let view = UILabel()
        view.textColor = .lightGray
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        [
            profileImageView,
            nameLabel,
            usernameLabel,
            valuelabel
        ].forEach({addSubview($0)})
        
        let imageSize:CGFloat = 40
        profileImageView.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: nil,
            trailing: nil,
            padding: .init(top: 5, left: 30, bottom: 5, right: 30),
            size: CGSize(width: imageSize, height: imageSize))
        profileImageView.layer.cornerRadius = imageSize/2
        
        nameLabel.anchor(top: nil, leading: profileImageView.trailingAnchor, bottom: profileImageView.centerYAnchor, trailing: nil,padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        usernameLabel.anchor(top: profileImageView.centerYAnchor, leading: nameLabel.leadingAnchor, bottom: nil, trailing: nil)
        valuelabel.anchor(top: nil, leading: nil, bottom: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 30))
        valuelabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 50).isActive  = true
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [nameLabel,
         usernameLabel,
         valuelabel].forEach({$0.text = nil})
        profileImageView.image = nil
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? Participant else {return}
        
        if vm.isFriend ?? false {
            valuelabel.text = "Friend"
        }
        
        nameLabel.text = vm.name
        if let urlString = vm.profileUrlString {
            profileImageView.sd_setImage(with: URL(string: urlString))
        }else {
            profileImageView.image =  UIImage(systemName: "person.circle")
        }
        if let username = vm.username {
            usernameLabel.text = "@\(username)"
        }else {
            usernameLabel.text = "Guest"
        }
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = vm.gender == genderType.male.rawValue ? UIColor.blueColor.cgColor : UIColor.redColor.cgColor
    }
    
    
}
