//
//  ChatConversationTableViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-18.
//

import UIKit
import SwipeCellKit
import SwiftDate

class ChatConversationTableViewCell: SwipeTableViewCell {
    static let identifier = "ChatConversationTableViewCell"
    
    // MARK: - Components
    private let channelImageView:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .lightGray
        view.backgroundColor = .secondarySystemBackground
        view.layer.masksToBounds = true
        return view
    }()
    
    private let channelName:UILabel = {
        let view = UILabel()
        view.font = .helveticaBold(ofSize: 18)
        return view
    }()
    
    private let lastMessage:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    private let dateLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = .secondaryLabel
        return view
    }()
    
    // MARK: - Class members
    var conversation:ConversationObject?{
        didSet{
            guard let users = conversation?.participants,
                  let username = UserDefaults.standard.string(forKey: "username")
            else {return}
            for user in users {
                if user.username != username {
                    channelName.text = user.name ?? user.username
                    if let imageUrl = user.profileUrlString {
                        channelImageView.sd_setImage(with: URL(string: imageUrl))
                    }
                    
                    if let latestMessage = conversation?.messages.last {
                        var lastMessageText = ""
                        
                        if !(latestMessage.sender?.username == username) {
                            lastMessageText = "\(user.name ?? user.username): \(latestMessage.text)"
                        }else {
                            lastMessageText = "你: \(latestMessage.text)"
                        }
                        lastMessage.text = lastMessageText
                        dateLabel.text = conversation?.lastUpdated?.toRelative(style:RelativeFormatter.twitterStyle())
                        
                    }
                    return
                }
            }
        }
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [channelImageView,channelName,lastMessage,dateLabel].forEach({
            contentView.addSubview($0)
        })
        
        let imageSize:CGFloat = 50
        channelImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil,padding: .init(top: 5, left: 5, bottom: 5, right: 5),size: .init(width: imageSize, height: imageSize))
        channelImageView.layer.cornerRadius = imageSize/2
        
        channelName.anchor(top: channelImageView.topAnchor, leading: channelImageView.trailingAnchor, bottom: nil, trailing: nil,padding: .init(top: 5, left: 10, bottom: 5, right: 5))
        
        lastMessage.anchor(top: channelName.bottomAnchor, leading: channelName.leadingAnchor, bottom: nil, trailing: nil)
        
        dateLabel.anchor(top: channelName.topAnchor, leading: nil, bottom: channelName.bottomAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        channelName.text = nil
        channelImageView.image = .personIcon
        lastMessage.text = nil
        dateLabel.text = nil
    }
    
}
