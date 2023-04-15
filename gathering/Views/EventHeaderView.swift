//
//  HeaderCollectionReusableView.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-18.
//

import UIKit

class EventHeaderView: UICollectionReusableView {
    
    static let identifier = "HeaderCollectionReusableView"
    
    var image:UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    
    private let imageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.fillSuperview()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setImageWithUrl(urlString:String,completion:@escaping (UIImage) -> Void){
        imageView.sd_setImage(with: URL(string: urlString)) { image, error, _, _ in
            if let image = image {
                completion(image)
            }
        }
    }
        
}
