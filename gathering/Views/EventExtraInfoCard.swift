//
//  EventExtraInfoCard.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-13.
//

import UIKit

class EventExtraInfoCard:UIView {
    
    private var vm:EventExtraInfoCardViewModel?
    private var numberOfLines = 4
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18,weight: .bold)
        return label
    }()
    
    private let infoLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14,weight: .light)
        return label
    }()
    
    private let button:UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitle("Show more", for: .normal)
        return button
    }()
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        [ titleLabel,infoLabel,button
        ].forEach{addSubview($0) }
        button.addTarget(self, action: #selector(didTapShowMore), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil)
        infoLabel.anchor(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        if infoLabel.countLines() >= 4 {
            infoLabel.numberOfLines = numberOfLines
            button.anchor(top: infoLabel.bottomAnchor, leading: infoLabel.leadingAnchor, bottom: bottomAnchor, trailing: nil)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: EventExtraInfoCardViewModel) {
        titleLabel.text = viewModel.title
        infoLabel.text = viewModel.info
        vm = viewModel
        
    }
    
    @objc private func didTapShowMore(){
        self.numberOfLines = 0
        self.infoLabel.numberOfLines = 0
        self.button.isHidden = true
        
    }
    
    
}

