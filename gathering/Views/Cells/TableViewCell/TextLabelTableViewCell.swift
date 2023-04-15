//
//  TextLabelTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-30.
//

import UIKit

class TextLabelTableViewCell: UITableViewCell {

    static let identifier = "TextLabelTableViewCell"
    
    let label:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 0
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,padding: .init(top: 10, left: 30, bottom: 10, right: 20))
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with text:String) {
        label.text = text
    }
    

}
