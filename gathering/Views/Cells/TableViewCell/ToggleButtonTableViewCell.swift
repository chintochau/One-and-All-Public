//
//  ToggleButtonTableViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-09.
//

import UIKit

protocol ToggleButtonTableViewCellDelegate:AnyObject {
    func ToggleButtonTableViewCellDidToggle(_ cell:ToggleButtonTableViewCell, afterValue:Bool, tag:Int)
}

class ToggleButtonTableViewCell: UITableViewCell {

    static let identifier = "ToggleButtonTableViewCell"
    
    weak var delegate: ToggleButtonTableViewCellDelegate?
    
    private let mainTitleLabel:UILabel = {
        let view = UILabel()
        
        return view
    }()
    
    private let toggleButton:UISwitch = {
        let view = UISwitch()
        return view
    }()
    
    private var tagNumber:Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        [mainTitleLabel,toggleButton].forEach({contentView.addSubview($0)})
        
        mainTitleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil,padding: .init(top: 5, left: 30, bottom: 5, right: 0))
        
        toggleButton.anchor(top: contentView.topAnchor, leading: nil, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 5, bottom: 5, right: 30))
        
        
        toggleButton.addTarget(self, action: #selector(didTapToggle), for: .valueChanged)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func configure(title:String, isOn:Bool, tag:Int) {
        mainTitleLabel.text = title
        toggleButton.isOn = isOn
        tagNumber = tag
    }
    
    @objc private func didTapToggle(){
        delegate?.ToggleButtonTableViewCellDidToggle(self, afterValue: toggleButton.isOn, tag: tagNumber)
    }
    
}
