//
//  GenderSelectionView.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-30.
//

import UIKit

protocol GenderSelectionViewDelegate:AnyObject {
    func GenderSelectionViewDidSelectItem(_ view:GenderSelectionView, item:String)
}

class GenderSelectionView: UIStackView {
    
    private var buttons = [UIButton]()
    
    weak var delegate:GenderSelectionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray.withAlphaComponent(0.5)
        layer.cornerRadius = 15
        axis = .vertical
        alignment = .center
        distribution = .fillEqually
        spacing = 5
        clipsToBounds = true
        
        genderType.allCases.forEach({
            let button = UIButton()
            button.setTitle($0.rawValue, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.addTarget(self, action: #selector(didSelectItem(_ :)), for: .touchUpInside)
            buttons.append(button)
        })
        
        buttons.forEach({
            addArrangedSubview($0)
        })
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didSelectItem(_ sender:UIButton){
        guard let text = sender.titleLabel?.text else {return}
        removeFromSuperview()
        delegate?.GenderSelectionViewDidSelectItem(self, item: text)
    }
    
    
}
