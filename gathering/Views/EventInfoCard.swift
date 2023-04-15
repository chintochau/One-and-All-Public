//
//  EventInfoCard.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-12.
//

import UIKit

class EventInfoCard:UIView {
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18,weight: .bold)
        return label
    }()
    
    private let subTitleLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14,weight: .light)
        return label
    }()
    
    private let icon:UIImageView = {
        let view = UIImageView()
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let button:UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(icon)
        addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        
        titleLabel.anchor(top: icon.topAnchor, leading: icon.trailingAnchor, bottom: nil, trailing: nil,padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        
        subTitleLabel.anchor(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        button.anchor(top: subTitleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: bottomAnchor, trailing: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with viewModel: InfoCardViewModel) {
        switch viewModel.infoType {
        case .location:
            icon.image = UIImage(systemName: "mappin.and.ellipse")
            button.setTitle("View on maps", for: .normal)
        case .refundPolicy:
            icon.image = UIImage(systemName: "dollarsign")
            button.frame = .zero
        case .time:
            icon.image = UIImage(systemName: "calendar")
            button.setTitle("Add to calendar", for: .normal)
        }
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
        
    }
    
    @objc private func didTapButton(){
        print("tapped")
    }
    
}

