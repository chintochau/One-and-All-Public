//
//  SectionHeaderView.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-25.
//

import UIKit

class SectionHeaderView: UIView {
    
    private let headerLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 24,weight: .bold)
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        headerLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with text:String){
        headerLabel.text = text
    }
}
