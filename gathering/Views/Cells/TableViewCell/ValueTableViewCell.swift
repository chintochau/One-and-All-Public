//
//  PickerTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-25.
//

import UIKit

class ValueTableViewCell: UITableViewCell {
    static let identifier = "ValueTableViewCell"
    
    
    let titleLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    let valueLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.numberOfLines = 2
        return view
    }()
    
    var index:Int = 0
    
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        contentView.addSubview(titleLabel)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: contentView.left+20, y: 0, width: contentView.width/3, height: contentView.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(withTitle title: String, value:String,index:Int = 0) {
        textLabel?.text = title
        detailTextLabel?.text = value
        detailTextLabel?.numberOfLines = 2
        self.index = index
    }
}
