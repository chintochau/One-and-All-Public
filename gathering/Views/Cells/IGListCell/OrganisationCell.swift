//
//  OrganisationCell.swift
//  One&All
//
//  Created by Jason Chau on 2023-04-05.
//

import Foundation
import IGListKit

class OrganisationCell:UICollectionViewCell, ListBindable {
    
    static let identifier = "OrganisationCell"
    
    private let profileImageView:UIImageView = {
        let view = UIImageView()
        
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let nameLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .medium)
        return view
        
    }()
    
    private let typeLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    
    private let introLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.numberOfLines = 0
        return view
    }()
    
    
    private let locationLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor  = .systemBackground
        
        [nameLabel,introLabel,profileImageView,typeLabel].forEach({
            addSubview($0)})
        
        setupConstrants()
        
    }
    
    private func setupConstrants () {
        
        let size:CGFloat = 100
        
        profileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil,padding: .init(top: 5, left: 5, bottom: 5, right: 0), size: .init(width: size, height: size))
        
        nameLabel.anchor(top: profileImageView.topAnchor, leading: profileImageView.trailingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 10, left: 10, bottom: 10, right: 10))
        
        typeLabel.anchor(top: nameLabel.bottomAnchor, leading: nameLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        introLabel.anchor(top: typeLabel.bottomAnchor, leading: nameLabel.leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 5, left: 0, bottom: 10, right: 10))
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [introLabel,nameLabel
        ].forEach( {
            $0.text = nil
        })
        
        profileImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? OrganisationViewModel else {return}
        
        nameLabel.text = viewModel.name
        introLabel.text = viewModel.intro
        profileImageView.sd_setImage(with: .init(string: viewModel.profileUrlString))
        typeLabel.text = viewModel.type
    }
}
