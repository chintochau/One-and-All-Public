//
//  ChatMessageTableViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-18.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

    static let identifier = "ChatMessageTableViewCell"
    
    // MARK: - Components
    private let messageText:UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    private let bubbleBackgroundView:UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.cornerRadius = 10
        return view
    }()
    
    // MARK: - Class members
    
    var leadingLayoutConstraint:NSLayoutConstraint!
    var trailingLayoutConstraint:NSLayoutConstraint!
    
    var chatMessage:MessageObject! {
        didSet {
            messageText.text = chatMessage.text
            bubbleBackgroundView.backgroundColor = chatMessage.isIncoming ? .secondarySystemBackground : .mainColor
            messageText.textColor = chatMessage.isIncoming ? .label :  .white
            
            leadingLayoutConstraint.isActive = chatMessage.isIncoming
            trailingLayoutConstraint.isActive = !chatMessage.isIncoming
            
        }
    }
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bubbleBackgroundView)
        contentView.addSubview(messageText)
        selectionStyle = .none
        
        
        let messagePadding:CGFloat = 25
        messageText.anchor(top: contentView.topAnchor, leading: nil, bottom: contentView.bottomAnchor, trailing: nil, padding: .init(top: 15, left: 0, bottom: 15, right: 0))
        messageText.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        leadingLayoutConstraint = messageText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: messagePadding)
        trailingLayoutConstraint = messageText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -messagePadding)
        
        
        let bubbleSpacing:CGFloat = 10
        bubbleBackgroundView.anchor(top: messageText.topAnchor, leading: messageText.leadingAnchor, bottom: messageText.bottomAnchor, trailing: messageText.trailingAnchor, padding: .init(top: -bubbleSpacing, left: -bubbleSpacing, bottom: -bubbleSpacing, right: -bubbleSpacing))
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
    
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct PreviewChat: PreviewProvider {
    
    static var previews: some View {
        // view controller using programmatic UI
        ChatMessageViewController(targetUsername: "jjchau").toPreview()
    }
}
#endif

