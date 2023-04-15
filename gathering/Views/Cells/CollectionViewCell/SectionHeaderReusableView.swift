//
//  SectionHeaderCollectionReusableView.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-06.
//

import UIKit

struct SectionHeaderViewModel {
    let title:String
    let buttonText:String?
    let index:Int
}

protocol SectionHeaderReusableViewDelegate:AnyObject {
    func SectionHeaderReusableViewDidTapActionButton(_ view: SectionHeaderRsuableView, button:UIButton)
}

class SectionHeaderRsuableView: UICollectionReusableView {
    static let identifier = "SectionHeaderRsuableView"
    
    weak var delegate:SectionHeaderReusableViewDelegate?
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 18)
        view.textColor = .label
        return view
    }()
    
    private let button:UIButton = {
        let view = UIButton(type: .system)
        view.setTitleColor(.link, for: .normal)
        view.titleLabel?.font = .robotoRegularFont(ofSize: 16)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(button)
        
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil,
                          padding: .init(top: 5, left: 30, bottom: 5, right: 0))
        
        button.anchor(top: titleLabel.topAnchor, leading: nil, bottom: titleLabel.bottomAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 30))
        button.addTarget(self, action: #selector(didTapShowAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with vm:SectionHeaderViewModel) {
        titleLabel.text = vm.title
        button.setTitle(vm.buttonText, for: .normal)
        button.tag = vm.index
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        button.setTitle(nil, for: .normal)
    }
    
    @objc private func didTapShowAll(){
        delegate?.SectionHeaderReusableViewDidTapActionButton(self, button: button)
    }
    
    
}
