//
//  TextViewCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-15.
//

import UIKit


class TextViewTableViewCell: UITableViewCell {
    static let identifier = "TextViewCollectionViewCell"
    
    
    let titleLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoMedium(ofSize: 16)
        return view
    }()
    
    let optionalLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        view.text = "(選填)"
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
    
    var isOptional:Bool = false {
        didSet {
            optionalLabel.isHidden = !isOptional
        }
    }
    
    private let separatorView:UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(optionalLabel)
        contentView.addSubview(separatorView)
        contentView.addSubview(textCount)
        selectionStyle = .none
        
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 25, left: 30, bottom: 0, right: 0))
        
        textCount.anchor(top: titleLabel.topAnchor, leading: nil, bottom: nil, trailing: contentView.trailingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 0, right: 30))
        
        textView.anchor(top: titleLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 10, left: 30, bottom: 0, right: 30))
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        optionalLabel.anchor(top: nil, leading: titleLabel.trailingAnchor, bottom: titleLabel.bottomAnchor, trailing: nil)
        
        separatorView.anchor(top: textView.bottomAnchor, leading: textView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: textView.trailingAnchor,padding: .init(top: 30, left: 0, bottom: 0, right: 0) , size: .init(width: 0, height: 5))
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        textCount.text = "\(text?.count ?? 0)/1000"
        self.isOptional = isOptional
    }
}
