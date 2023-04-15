//
//  UserTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-30.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    static let identifier = "UserTableViewCell"
    
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
        view.font = .systemFont(ofSize: 20)
        return view
    }()
    private let usernameLabel:UILabel = {
        let view  = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 1
        return view
    }()
    
    lazy var valuelabel:UILabel = {
        let view = UILabel()
        view.textColor = .extraLightGray
        view.numberOfLines = 1
        view.font = .robotoRegularFont(ofSize: 14)
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle = .default, reuseIdentifier: String? = "UserTableViewCell") {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        [
            profileImageView,
            nameLabel,
            usernameLabel,
            valuelabel
        ].forEach({contentView.addSubview($0)})
        
        let imageSize:CGFloat = 50
        profileImageView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: nil,
            padding: .init(top: 5, left: 20, bottom: 5, right: 0),
            size: CGSize(width: imageSize, height: imageSize))
        profileImageView.layer.cornerRadius = imageSize/2
        
        nameLabel.anchor(top: nil, leading: profileImageView.trailingAnchor, bottom: contentView.centerYAnchor, trailing: nil,padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        usernameLabel.anchor(top: contentView.centerYAnchor, leading: nameLabel.leadingAnchor, bottom: nil, trailing: nil)
        
        valuelabel.anchor(top: nil, leading: nil, bottom: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 20))
        valuelabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [nameLabel,
         usernameLabel].forEach({$0.text = nil})
        profileImageView.image = nil
    }
    
    func configure(with vm:User){
        nameLabel.text = vm.name
        usernameLabel.text = "@\(vm.username)"
        if let urlString = vm.profileUrlString {
            profileImageView.sd_setImage(with: URL(string: urlString))
        }
        if let gender = vm.gender {
            profileImageView.layer.borderWidth = 0.5
            profileImageView.layer.borderColor = gender == genderType.male.rawValue ? UIColor.blueColor.cgColor : UIColor.redColor.cgColor
        }
    }
    
    func configure(with vm:Participant){
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
    }
    
    func configure(with vm:UserObject,isSelected:Bool = false){
        nameLabel.text = vm.name
        usernameLabel.text = "@\(vm.username)"
        if let urlString = vm.profileUrlString {
            profileImageView.sd_setImage(with: URL(string: urlString))
        }
        
        accessoryView?.isHidden = !isSelected
    }
    
    
    
}
