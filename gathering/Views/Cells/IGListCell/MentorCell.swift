//
//  MentorCell.swift
//  One&All
//
//  Created by Jason Chau on 2023-04-05.
//

import Foundation
import IGListKit


class MentorCell:UICollectionViewCell, ListBindable {
    
    private let profileImageView:UIImageView = {
        let view = UIImageView()
        view.clipsToBounds =  true
        
        return view
    }()
    
    private let nameLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 20, weight: .medium)
        return view
    }()
    
    private let expertiseLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 0
        return view
    }()
    
    private let contactLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    private let bioLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor  = .systemBackground
        [nameLabel,profileImageView,expertiseLabel,contactLabel,bioLabel].forEach({addSubview($0)})
        
        profileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 10, bottom: 10, right: 0), size: .init(width: 120, height: 120))
        profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20).isActive = true
        
        nameLabel.anchor(top: profileImageView.topAnchor, leading: profileImageView.trailingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 5, bottom: 5, right: 5))
        
        expertiseLabel.anchor(top: nameLabel.bottomAnchor, leading: nameLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        contactLabel.anchor(top: expertiseLabel.bottomAnchor, leading: expertiseLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 5))
        
        bioLabel.anchor(top: contactLabel.bottomAnchor, leading: nameLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        bioLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,constant: -20).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        expertiseLabel.text = nil
        contactLabel.text = nil
        bioLabel.text = nil
        profileImageView.image = nil
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MentorViewModel else {return}
        
        profileImageView.sd_setImage(with: .init(string: viewModel.urlString))
        nameLabel.text = viewModel.name
        expertiseLabel.text = viewModel.expertise
        contactLabel.text = viewModel.phone
        bioLabel.text = viewModel.bio
        
    }
    
    
}
