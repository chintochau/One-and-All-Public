//
//  TextViewCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-12.
//

import UIKit

class TextViewCollectionViewCell: UICollectionViewCell {
    static let identifier = "TextViewCollectionViewCell"
    
    
    let titleLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoMedium(ofSize: 16)
        return view
    }()
    
    
    let textCount:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        return view
    }()
    
    let textView:UITextView = {
        let view = UITextView()
        view.textColor = .label
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.isScrollEnabled = false
        view.font = .preferredFont(forTextStyle: .body)
        view.layer.borderColor = UIColor.darkMainColor.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        return view
    }()
    
    let sendButton:UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "paperplane"), for: .normal)
        view.tintColor = .darkMainColor
        view.imageView?.contentMode = .scaleAspectFit
        view.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        return view
    }()
    
    
    private let separatorView:UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        addSubview(titleLabel)
        addSubview(separatorView)
        addSubview(textCount)
        addSubview(sendButton)
        
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 0, left: 30, bottom: 0, right: 0))
        
        textCount.anchor(top: textView.topAnchor, leading: nil, bottom: nil, trailing: textView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        
        textView.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 10, left: 30, bottom: 0, right: 30))
        let heightConstrant = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        heightConstrant.priority = .defaultHigh
        heightConstrant.isActive = true
        
        sendButton.anchor(top: nil, leading: nil, bottom: textView.bottomAnchor, trailing: textView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 0),size: .init(width: 50, height: 50))
        
        
        separatorView.anchor(top: textView.bottomAnchor, leading: textView.leadingAnchor, bottom: bottomAnchor, trailing: textView.trailingAnchor,padding: .init(top: 5, left: 0, bottom: 0, right: 0) , size: .init(width: 0, height: 5))
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
        titleLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withTitle title: String, text:String?,tag:Int = 0,_ isOptional:Bool = false) {
        titleLabel.text = title
        textView.text = text
        textView.tag = tag
        textCount.text = "\(text?.count ?? 0)/100"
    }
    
    
    
}
