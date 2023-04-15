//
//  FriendTableViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-09.
//

import UIKit


protocol FriendTableViewCellDelegate:AnyObject {
    func FriendTableViewCellDidTapFollow(_ cell:FriendTableViewCell)
}

class FriendTableViewCell:UITableViewCell {
    static let identifier = "FriendTableViewCell"
    
    weak var delegate:FriendTableViewCellDelegate?
    
    private let profileImageView:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .lightGray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let nameLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoMedium(ofSize: 18)
        return view
    }()
    
    private let idLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 14)
        return view
    }()
    
    private lazy var friendButton:UIButton = {
        let view = UIButton(type: .system)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .lightGray
        view.titleLabel?.font = .systemFont(ofSize: 16)
        view.setTitleColor(.white, for: .normal)
        return view
    }()
    
    private let username:String
    private var userObject:UserObject? {
        didSet {
            guard let userObject = userObject else {return}
            
            self.nameLabel.text = userObject.name
            
            if let profileUrl = userObject.profileUrlString {
                self.profileImageView.sd_setImage(with: URL(string: profileUrl))
            }
            
        }
    }
    
    
    
    var relationship:RelationshipObject? {
        didSet {
            
            if let status = relationship?.status {
                switch status {
                case relationshipType.noRelation.rawValue:
                    friendButton.setTitle("Add Friend", for: .normal)
                    friendButton.backgroundColor = .extraLightGray
                    
                case relationshipType.friend.rawValue:
                    friendButton.setTitle("Friend", for: .normal)
                    friendButton.backgroundColor = .mainColor
                    
                case relationshipType.blocked.rawValue:
                    friendButton.setTitle("Blocked", for: .normal)
                    friendButton.backgroundColor = .redColor
                    
                case relationshipType.pending.rawValue:
                    friendButton.setTitle("Requested", for: .normal)
                    friendButton.backgroundColor = .lightGray
                    
                case relationshipType.received.rawValue:
                    friendButton.setTitle("Accept", for: .normal)
                    friendButton.backgroundColor = .link
                    
                default:
                    print("relationship not handled")
                }
                
            }
        }
    }
    
    
    init(username:String) {
        self.username = username
        super.init(style: .default, reuseIdentifier: FriendTableViewCell.identifier)
        
        idLabel.text = "@\(username)"
        
        [profileImageView,nameLabel,idLabel,friendButton].forEach({contentView.addSubview($0)})
        
        let imageSize:CGFloat = 50
        profileImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil,padding: .init(top: 5, left: 10, bottom: 5, right: 0),size: .init(width: imageSize, height: imageSize))
        profileImageView.layer.cornerRadius = imageSize/2
        
        nameLabel.anchor(top: nil, leading: profileImageView.trailingAnchor, bottom: contentView.centerYAnchor, trailing: nil,
                         padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        idLabel.anchor(top: contentView.centerYAnchor, leading: nameLabel.leadingAnchor, bottom: nil, trailing: nil)
        
        friendButton.anchor(top: nil, leading: nil, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 10),size: .init(width: 90, height: 30))
        friendButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        friendButton.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        
        
        getUserRealmObject(username)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    fileprivate func getUserRealmObject(_ username: String) {
        if let userObject = RealmManager.shared.getObject(ofType: UserObject.self, forPrimaryKey: username) {
            
            self.userObject = userObject
            
        }else {
            DatabaseManager.shared.findUserWithUsername(with: username) {[weak self] user in
                
                if let userObject = user?.realmObject() {
                    self?.userObject = userObject
                }
            }
        }
    }
    
    
    @objc private func didTapFollow(){
        guard var status = relationship?.status, let targetUsername = userObject?.username else {return}
        switch status {
            
        case relationshipType.noRelation.rawValue:
            status = relationshipType.pending.rawValue
            DatabaseManager.shared.sendFriendRequest(targetUsername: targetUsername)
            print("pending")
            
        case relationshipType.friend.rawValue:
            // Prompt to confirm, tap to unfriend
            status = relationshipType.noRelation.rawValue
            DatabaseManager.shared.cancelFriendRequestAndUnfriend(targetUsername: targetUsername)
            
            print("noRelation")
        case relationshipType.pending.rawValue:
            // Tap to cancel request
            status = relationshipType.noRelation.rawValue
            DatabaseManager.shared.cancelFriendRequestAndUnfriend(targetUsername: targetUsername)
            
            print("noRelation")
        case relationshipType.received.rawValue:
            // tap to accept
            status = relationshipType.friend.rawValue
            // impelemtn add friend
            DatabaseManager.shared.acceptFriendRequest(targetUsername: targetUsername)
            
            print("friend")
        case relationshipType.blocked.rawValue:
            print("Blocked: should not happen")
        default:
            print("Default: should not happen")
        }
        
        delegate?.FriendTableViewCellDidTapFollow(self)
    }
    
    public func updateUserProfile(){
        
        DatabaseManager.shared.findUserWithUsername(with: username) {[weak self] user in
            
            if let userObject = user?.realmObject() {
                
                self?.userObject = userObject
            }
        }
    }
    
}
