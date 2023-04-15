//
//  TitleWithImageTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-05.
//

import UIKit

class TitleWithImageTableViewCell: UITableViewCell {
    
    static let identifier = "TitleWithImageTableViewCell"
    
    let emojiButton:UIButton = {
        let view = UIButton()
        if let emoji = UserDefaults.standard.string(forKey: "selectedEmoji") {
            view.setTitle(emoji, for: .normal)
        }else {
            view.setTitle("😃", for: .normal)
        }
        view.titleLabel?.font = .systemFont(ofSize: 35)
        return view
    }()
    
    let titleField:PaddedTextField = {
        let view = PaddedTextField()
        view.placeholder = "Title"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.darkMainColor.cgColor
        view.layer.cornerRadius = 5
        
        let leftView = UIView()
        leftView.backgroundColor = .lightFillColor
        leftView.layer.borderWidth = 1
        leftView.layer.borderColor = UIColor.darkMainColor.cgColor
        leftView.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.down")
        arrowImageView.frame = CGRect(x: 55, y: 20, width: 10, height: 10)
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = .darkMainColor
        leftView.addSubview(arrowImageView)
        
        view.leftView = leftView
        view.leftViewMode = .always
        view.layer.masksToBounds = true
        return view
    }()
    
    let titleLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoMedium(ofSize: 16)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(titleField)
        contentView.addSubview(titleLabel)
        
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 25, left: 30, bottom: 0, right: 30))
        
        let imageSize:CGFloat = 50
        
        titleField.anchor(top: titleLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,padding: .init(top: 10, left: 30, bottom: 0, right: 30),size: .init(width: 0, height: imageSize))
        
        
        
        titleField.leftView?.addSubview(emojiButton)
        
        emojiButton.frame = CGRect(x: 10, y: 0, width: 50, height: 50)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
