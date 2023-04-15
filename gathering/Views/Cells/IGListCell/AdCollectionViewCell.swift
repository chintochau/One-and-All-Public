//
//  AdCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-20.
//

import UIKit
import IGListKit

class AdCollectionViewCell: UICollectionViewCell,ListBindable {
    static let identifier = "AdCollectionViewCell"
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,
                          padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? AdViewModel else { return }
        // Update the cell with the event information
        titleLabel.text = "This is Ad"
    }
    
    
}

