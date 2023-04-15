//
//  TextLabelCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-13.
//

import UIKit

class TextLabelCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TextLabelCollectionViewCell"
    
    private let textlabel:UILabel = {
        let view = UILabel()
        view.font = .robotoSemiBoldFont(ofSize: 26)
        view.numberOfLines = 4
        view.textAlignment = .left
        return view
    }()
    
    var title:String? {
        didSet{
            textlabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textlabel)
        textlabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                         padding: .init(top: 10, left: 30, bottom: 10, right: 30))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
