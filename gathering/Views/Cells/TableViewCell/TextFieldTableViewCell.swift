//
//  TextFieldCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-15.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    static let identifier = "TextFieldCollectionViewCell"
    
    let titleLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    let textField:UITextField = {
        let view = UITextField()
        view.backgroundColor = .clear
        view.textColor = .label
        view.textAlignment = .right
//        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        view.leftViewMode = .always
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        contentView.addSubview(titleLabel)
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: contentView.left+20, y: 0, width: titleLabel.width, height: contentView.height)
        textField.frame = CGRect(x: titleLabel.right+5, y: 0, width: contentView.width-titleLabel.width-45, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        textField.placeholder = nil
        titleLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(withTitle title: String, placeholder:String, text:String = "") {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.text = text
    }
    
    
}

