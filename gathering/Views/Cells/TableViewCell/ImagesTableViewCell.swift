//
//  SingleImageTableViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-08.
//

import UIKit

protocol SingleImageTableViewCellDelegate:AnyObject {
    
}

class ImagesTableViewCell: UITableViewCell {

    static let identifier = "SingleImageTableViewCell"

    weak var delegate:SingleImageTableViewCellDelegate?
    
    private let coverImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "photo.on.rectangle.angled")
        view.tintColor = .lightGray.withAlphaComponent(0.5)
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    
    // Three right-hand-side image views
    private let rightImageView1 = makeRightImageView()
    private let rightImageView2 = makeRightImageView()
    private let rightImageView3 = makeRightImageView()
    
    // Helper method to create the right-hand-side image views
       private static func makeRightImageView() -> UIImageView {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           imageView.clipsToBounds = true
           imageView.layer.cornerRadius = 8.0
           imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
           imageView.backgroundColor = .secondarySystemBackground
           imageView.tintColor = .lightGray.withAlphaComponent(0.5)
           return imageView
       }
    
    // Array of images mapped to the image views
    var images: [UIImage] = [] {
        didSet {
            guard !images.isEmpty else {return}
            
            coverImageView.image = images.first
            coverImageView.contentMode = .scaleAspectFill
            
            if images.count >= 2 {
                rightImageView1.image = images[1]
                rightImageView1.contentMode = .scaleAspectFill
            }
            if images.count >= 3 {
                rightImageView2.image = images[2]
                rightImageView2.contentMode = .scaleAspectFill
            }
            
            if images.count >= 4 {
                rightImageView3.image = images[3]
                rightImageView3.contentMode = .scaleAspectFill
            }
        }
    }
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(coverImageView)
        
        contentView.addSubview(rightImageView1)
        contentView.addSubview(rightImageView2)
        contentView.addSubview(rightImageView3)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureImageViews(with width:CGFloat){
        
        
        let largeImageSize:CGFloat = (width-60)*3/4
        let smallImageSize:CGFloat = largeImageSize/3-1
        
        coverImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 30, bottom: 0, right: 0),size: .init(width: largeImageSize, height: largeImageSize))
        
        rightImageView1.anchor(top: contentView.topAnchor, leading: coverImageView.trailingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0), size: CGSize(width: smallImageSize, height: smallImageSize))

        rightImageView2.anchor(top: rightImageView1.bottomAnchor, leading: coverImageView.trailingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 0), size: CGSize(width: smallImageSize, height: smallImageSize))

        rightImageView3.anchor(top: rightImageView2.bottomAnchor, leading: coverImageView.trailingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 0), size: CGSize(width: smallImageSize, height: smallImageSize))

        
    }
    
}
