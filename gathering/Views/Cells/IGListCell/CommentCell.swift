//
//  EventCommentsCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-12.
//

import UIKit
import IGListKit
import SwiftDate

class CommentCell: UICollectionViewCell,ListBindable {
    static let identifier = "CommentCell"
    
    
    private let senderLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14,weight: .semibold)
        return view
    }()
    
    private let messageLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 0
        return view
    }()
    private let dateLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 12)
        view.textColor = .lightGray
        return view
    }()
    
    
    private var comment:Comment?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [senderLabel,messageLabel,dateLabel].forEach({addSubview($0)})
        
        senderLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 5, left: 30, bottom: 0, right: 30))
        messageLabel.anchor(top: senderLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 5, left: 30, bottom: 0, right: 30))
        dateLabel.anchor(top: messageLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 5, left: 30, bottom: 10, right: 30))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? Comment else {return}
        messageLabel.text = vm.message
        senderLabel.text = vm.sender
        
        let date = vm.timestamp.toDate()
        let dateString = String.localeDate(from: date, .zhHantTW)
        var dateText = date.toRelative()
        
        dateLabel.text = dateText
        
    }
    
}

struct Comment:Codable {
    
    let sender: String
    let message: String
    let timestamp: Double
    
}


