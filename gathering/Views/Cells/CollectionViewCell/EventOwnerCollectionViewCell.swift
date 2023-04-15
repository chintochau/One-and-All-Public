//
//  EventOwnerCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-20.
//

import UIKit
import IGListDiffKit

protocol EventOwnerCollectionViewCellDelegate:AnyObject {
    func EventOwnerCollectionViewCellDidTapMessage(_ cell:EventOwnerCollectionViewCell, username:String?)
}


class EventOwnerCollectionViewCell: UICollectionViewCell {
    static let identifier = "EventOwnerCollectionViewCell"
    
    weak var delegate:EventOwnerCollectionViewCellDelegate?
    
    private let imageView:UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .secondarySystemBackground
        view.image = .personIcon
        view.tintColor = .lightGray
        return view
    }()
    
    private let nameLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        return view
    }()
    
    
    private let messageButton:UIButton = {
        let view = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        view.setImage(UIImage(systemName: "text.bubble",withConfiguration: config), for: .normal)
        view.tintColor = .darkMainColor
        return view
    }()
    
    
    
    
    var user:User? {
        didSet {
            if user?.username == UserDefaults.standard.string(forKey: "username") {
                messageButton.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [imageView,nameLabel,messageButton].forEach({addSubview($0)})
        
        let cellHeight:CGFloat = 45
        let padding:CGFloat = 3
        let imageSize:CGFloat = cellHeight - 2*padding
        
        heightAnchor.constraint(equalToConstant: cellHeight).isActive = true
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: padding, left: 30, bottom: 0, right: 0),size: .init(width: imageSize, height: imageSize))
        imageView.layer.cornerRadius = imageSize/2
        
        nameLabel.anchor(top: nil, leading: imageView.trailingAnchor, bottom: nil, trailing: messageButton.leadingAnchor,padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        messageButton.anchor(top: nil, leading: nil, bottom: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 30))
        messageButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with user:User?) {
        
        guard let user = user else {return}
        nameLabel.text = user.name
        if let urlString = user.profileUrlString {
            imageView.sd_setImage(with: URL(string: urlString))
        }
        self.user = user
        
    }
    
    @objc private func didTapFollow(){
        guard let user = user else {return}
        
    }
    
    @objc private func didTapMessage(){
        delegate?.EventOwnerCollectionViewCellDidTapMessage(self, username: user?.username)
    }
    
    
}

class OwnerViewModel:ListDiffable {
    var user:User
    var id:String {
        user.username
    }
    
    init(user: User) {
        self.user = user
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object  = object as? EventParticipantsViewModel else {return false}
        return id == object.id
    }
    
}
