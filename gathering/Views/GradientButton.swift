//
//  GradientButton.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-27.
//

import UIKit

class GradientButton: UIButton {
    var gradientLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        titleLabel?.font = .robotoRegularFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gradientLayer = self.gradientLayer {
            gradientLayer.frame = self.bounds
        }
        
        
    }
    
    func setGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint,image:UIImage? = nil) {
        if let gradientLayer = self.gradientLayer {
            gradientLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
        
        let imageView = UIImageView(image: image)
        let padding:CGFloat = 15
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        imageView.tintColor = UIColor(named: "darkSecondaryColor")
        self.bringSubviewToFront(imageView)
    }
}
