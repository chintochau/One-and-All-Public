//
//  ContactButton.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-25.
//

import UIKit


class ContactButton:UIView {
    
    var isSelected:Bool = false {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.darkMainColor.cgColor
                
                
            }else {
                
                layer.borderColor = UIColor.opaqueSeparator.cgColor
                
                
            }
        }
    }
    
    private let contactTitleLabel:UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return view
    }()
    
    private let inputTextField:UITextField = {
        let view = UITextField()
        view.clipsToBounds = true
        view.borderStyle = .roundedRect
        view.backgroundColor = .secondarySystemBackground
        return view
        
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [contactTitleLabel,inputTextField].forEach({addSubview($0)})
        layer.cornerRadius = 15
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.opaqueSeparator.cgColor
        contactTitleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 20, left: 20, bottom: 5, right: 20))
        inputTextField.anchor(top: contactTitleLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 20, bottom: 20, right: 120))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(title:String, text:String?) {
        contactTitleLabel.text = title
        inputTextField.text = text
    }
    
}
