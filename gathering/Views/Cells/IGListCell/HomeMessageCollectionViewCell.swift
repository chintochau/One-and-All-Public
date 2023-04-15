//
//  HomeMessageCollectionViewCell.swift
//  One&All
//
//  Created by Jason Chau on 2023-04-05.
//

import Foundation
import IGListKit

class HomeMessageCollectionViewCell: UICollectionViewCell,ListBindable {
    static let identifier = "HomeMessageCollectionViewCell"
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = .mainTextColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .lightMainColor
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,
                          padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? HomeMessageViewModel else { return }
        // Update the cell with the event information
        titleLabel.text = vm.message
    }
    
    
}

