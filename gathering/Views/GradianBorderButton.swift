//
//  GradianBorderButton.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-02.
//

import UIKit

class GradianBorderButton: UIView {
    
    private let titleText:UILabel = {
        let view = UILabel()
        view.textColor = .darkSecondaryColor
        view.font = .systemFont(ofSize: 24, weight: .semibold)
        return view
        
    }()
    
    private let subText:UILabel = {
        let view = UILabel()
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14, weight: .medium)
        return view
    }()
    
    var titleString:String?{
        didSet{
            titleText.text = titleString
        }
    }
    var subString:String?{
        didSet{
            
            subText.text = subString
        }
    }
    
    
    private var tapAction: (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        [titleText,subText].forEach({addSubview($0)})
        titleText.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: nil,padding: .init(top: 15, left: 0, bottom: 0, right: 0))
        titleText.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        subText.anchor(top: titleText.bottomAnchor, leading: nil, bottom: nil, trailing: nil,padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        subText.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create a CAGradientLayer instance and set its properties
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.lightMainColor.cgColor, UIColor.darkMainColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 10

        // Create a CAShapeLayer instance and set its properties
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 4
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.frame = bounds
        
        // Add the gradient layer and shape layer as sublayers of the view's layer
        layer.addSublayer(gradientLayer)
        layer.addSublayer(shapeLayer)
        
        // Set the mask of the gradient layer to the shape layer
        gradientLayer.mask = shapeLayer
        
    }
    
    func setupTapGesture(action: @escaping () -> Void) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        tapAction = action
    }
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }
    
    
}
