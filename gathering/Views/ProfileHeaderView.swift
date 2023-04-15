//
//  ProfileHeaderView.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-25.
//

import UIKit

struct ProfileHeaderViewViewModel {
    let profileUrlString:String?
    let username:String
    let name:String?
    
    init(user:User) {
        self.profileUrlString = user.profileUrlString
        self.username = "@\(user.username)"
        self.name = user.name
    }
}

class ProfileHeaderView: UIView {
    
    let imageView:UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.image = UIImage(systemName: "person.crop.circle")
        view.tintColor = .lightGray
        view.backgroundColor = .secondarySystemBackground
        view.isUserInteractionEnabled = true
        return view
        
    }()
    
    let editIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "pencil.circle.fill"))
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()
    
    private let nameLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .helveticaBold(ofSize: 24)
        return view
        
    }()
    private let usernameLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .helvetica(ofSize: 16)
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [
            imageView,
            nameLabel,
            usernameLabel,
            editIconImageView
        ].forEach({addSubview($0)})
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = width/4
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        
        let editIconSize: CGFloat = 24
        editIconImageView.frame = CGRect(
            x: imageView.frame.maxX - editIconSize,
            y: imageView.frame.maxY - editIconSize,
            width: editIconSize,
            height: editIconSize
        )
        
        
        nameLabel.frame = CGRect(x: 40, y: imageView.bottom+10, width: width-80, height: 30)
        usernameLabel.frame = CGRect(x: 40, y: nameLabel.bottom, width: width-80, height: 30)
    }
    
    func configure(with vm:ProfileHeaderViewViewModel) {
        if let urlString = vm.profileUrlString{
        imageView.sd_setImage(with: URL(string: urlString))}
        
        usernameLabel.text = vm.username
        nameLabel.text = vm.name
        
    }
    
    func showEditButton(){
        editIconImageView.isHidden = false
    }
    
}
