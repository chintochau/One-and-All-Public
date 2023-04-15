//
//  ProfileHeaderCollectionReusableView.swift
//  Pods
//
//  Created by Jason Chau on 2023-02-08.
//

import UIKit

protocol ProfileHeaderReusableViewDelegate:AnyObject {
    func ProfileHeaderReusableViewDelegatedidTapMessage(_ header:UICollectionReusableView, user:User)
    func ProfileHeaderDelegateDidTapFollowBUtton(_ header:UICollectionReusableView, user:User)
}

class UserProfileHeaderReusableView: UICollectionReusableView {
    
    static let identifier = "ProfileHeaderCollectionReusableView"

    weak var delegate:ProfileHeaderReusableViewDelegate?

    // MARK: - components
    
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    let nameLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 20)
        view.textColor = .label
        view.textAlignment = .center
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = .personIcon
        iv.tintColor = .lightGray
        iv.backgroundColor = .systemBackground
        return iv
    }()
    
    private let followButton:UIButton = {
        let view = UIButton()
        view.setTitle("Follow", for: .normal)
        view.setTitleColor(.link, for: .normal)
        view.layer.cornerRadius  = 5
        view.clipsToBounds = true
        return view
    }()
    
    private let messageButton:UIButton = {
        let view = UIButton()
        view.setTitle("Message", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = .lightGray
        view.layer.cornerRadius  = 5
        view.clipsToBounds = true
        return view
    }()
    
    private let messageLabel:UILabel = {
        let view = UILabel()
        view.font = .helveticaBold(ofSize: 20)
        view.text = "已參加活動: "
        return view
    }()
    
    
    // MARK: - Class members
    
    var user:User? {
        didSet {
            guard let user = user else {return}
            
            if user.username == UserDefaults.standard.string(forKey: "username") {
                followButton.isHidden = true
                messageButton.isHidden = true
            }
            
            usernameLabel.text = user.username
            nameLabel.text = user.name
            
            if let profileUrlString = user.profileUrlString {
                profileImageView.sd_setImage(with: URL(string: profileUrlString))
            }
            
            let relationship = user.getRelationshipObject()
            friendStatus = relationship?.status ?? 0
        }
    }
    
    var friendStatus:Int? = 0 {
        didSet {
            switch friendStatus {
            case relationshipType.friend.rawValue:
                followButton.setTitle("Friend", for: .normal)
                followButton.setTitleColor(.white, for: .normal)
                followButton.backgroundColor = .mainColor
                
            case relationshipType.pending.rawValue:
                followButton.setTitle("Requested", for: .normal)
                followButton.backgroundColor = .lightGray
                
            case relationshipType.blocked.rawValue:
                print("Blocked, Should not happen")
                
                
                
            case relationshipType.received.rawValue:
                followButton.setTitle("Accept", for: .normal)
                followButton.setTitleColor(.white, for: .normal)
                followButton.backgroundColor = .link
                
                
            case relationshipType.noRelation.rawValue:
                followButton.setTitle("Add", for: .normal)
                followButton.setTitleColor(.white, for: .normal)
                followButton.backgroundColor = .link
                
                
            default:
                print("Not yet implemented")
            }
            
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [
            nameLabel,
            usernameLabel,
            profileImageView,
            followButton,
            messageButton,
            messageLabel
        ].forEach({addSubview($0)})
        
        let imageSize:CGFloat = 80
        
        backgroundColor = .systemBackground
        
        profileImageView.anchor(
            top: topAnchor,
            leading: nil,
            bottom: nil,
            trailing: nil,
            padding: .init(top: 40, left: 0, bottom: 0, right: 0),
            size: CGSize(width: imageSize, height: imageSize))
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        profileImageView.layer.cornerRadius = imageSize/2
        
        nameLabel.anchor(top: profileImageView.bottomAnchor, leading: nil, bottom: nil, trailing: nil)
        nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        usernameLabel.anchor(
            top: nameLabel.bottomAnchor,
            leading: nil,
            bottom: nil,
            trailing: nil)
        usernameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        
        
        messageLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 5, left: 20, bottom: 5, right: 20))
        
        let buttonSize:CGFloat = (width-60)/2
        
        followButton.anchor(top: nil, leading: leadingAnchor, bottom: messageLabel.topAnchor, trailing: nil,padding: .init(top: 0, left: 20, bottom: 10, right: 0),size: CGSize(width: buttonSize, height: 30))
        followButton.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        
        
        messageButton.anchor(top: followButton.topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 20),size: CGSize(width: buttonSize, height: 30))
        messageButton.addTarget(self, action: #selector(didTapMessage), for: .touchUpInside)
        
    
        [messageButton,followButton].forEach({
            $0.isHidden = !AuthManager.shared.isSignedIn
        })
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func didTapFollow(){
        switch friendStatus {
        case relationshipType.noRelation.rawValue:
            friendStatus = relationshipType.pending.rawValue
            DatabaseManager.shared.sendFriendRequest(targetUsername: user!.username)
            print("pending")
            
        case relationshipType.friend.rawValue:
            // Prompt to confirm, tap to unfriend
            friendStatus = relationshipType.noRelation.rawValue
            DatabaseManager.shared.cancelFriendRequestAndUnfriend(targetUsername: user!.username)
            
            print("noRelation")
        case relationshipType.pending.rawValue:
            // Tap to cancel request
            friendStatus = relationshipType.noRelation.rawValue
            DatabaseManager.shared.cancelFriendRequestAndUnfriend(targetUsername: user!.username)
            
            print("noRelation")
        case relationshipType.received.rawValue:
            // tap to accept
            friendStatus = relationshipType.friend.rawValue
            // impelemtn add friend
            DatabaseManager.shared.acceptFriendRequest(targetUsername: user!.username)
            
            print("friend")
        case relationshipType.blocked.rawValue:
            print("Blocked: should not happen")
        default:
            print("Default: should not happen")
        }
        
        delegate?.ProfileHeaderDelegateDidTapFollowBUtton(self, user: user!)
    }
    
    @objc private func didTapMessage(){
        delegate?.ProfileHeaderReusableViewDelegatedidTapMessage(self, user: user!)
    }
    
}


#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct USErPreview: PreviewProvider {
    
    static var previews: some View {
        // view controller using programmatic UI
        UserProfileViewController(user: .init(username: "jjchauu", email: nil, name: "Jason Chau", profileUrlString: nil, gender: nil)).toPreview()
    }
}
#endif

