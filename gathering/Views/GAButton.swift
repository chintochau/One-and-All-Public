//
//  GAButton.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-16.
//

import UIKit

class GAButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .mainColor
        layer.cornerRadius = 10
        tintColor = .streamWhiteSnow
        titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    convenience init(title: String,height:CGFloat = 50, type: UIButton.ButtonType = .system) {
        self.init(type: type)
        setTitle(title, for: .normal)
        backgroundColor = .mainColor
        layer.cornerRadius = 10
        tintColor = .streamWhiteSnow
        titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    
    
    
    
}
