//
//  NotificationCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-15.
//

import UIKit
import IGListKit
import SwiftDate

class NotificationCollectionViewCell: UICollectionViewCell, ListBindable {
    
    static let identifier = "NotificationCollectionViewCell"
    
    
    private let profileImageView:UIImageView = {
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = .personIcon
        view.tintColor = .lightGray
        return view
        
    }()
    
    private let titleLabel:UILabel  = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.numberOfLines = 3
        return view
    }()
    
    private let subtitleLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    private let dateLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .right
        view.font = .robotoRegularFont(ofSize: 12)
        view.textColor = .extraLightGray
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [dateLabel,titleLabel,subtitleLabel,profileImageView].forEach({
            addSubview($0)
        })
        
        profileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 10, left: 20, bottom: 10, right: 0), size: .init(width: 40, height: 40))
        profileImageView.layer.cornerRadius = 20
        
        titleLabel.anchor(top: topAnchor, leading: profileImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 10, left: 10, bottom: 10, right: 20))
        dateLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 5, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// bind a GANotification
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? GANotification else {return}
        
        let user = vm.sentUser
        let name = user?.name ?? user?.username ?? "你老友"
        let event = vm.event
        let eventName = event?.name ?? "活動"
        
        if let imageUrl = user?.urlString {
            profileImageView.sd_setImage(with: .init(string: imageUrl))
        }
        
        switch vm.type {
        case .friendRequest:
            titleLabel.text = "\(name)邀請你成為好友"
        case .eventJoin:
            titleLabel.text = "\(name)參加了\(eventName)"
        case .eventInvite:
            titleLabel.text = "\(name)邀請你參加: \(event?.name ?? "活動")"
        case .eventUpdate:
            titleLabel.text = "Event Update"
        case .friendAccept:
            titleLabel.text = "\(name)與你成為好友"
        }
        
        dateLabel.text = vm.createdAt.toDate().toRelative(style: RelativeFormatter.twitterStyle())
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = .personIcon
    }
    
    
}
