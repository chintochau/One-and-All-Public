//
//  CustomModalViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-02.
//

import UIKit

class CustomModalViewController: UIViewController {
    
    let contentView:UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
//        view.layer.borderColor = UIColor.opaqueSeparator.cgColor
//        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        return view
    }()
    
    
    private let closeButton:UIButton = {
        let view = UIButton()
        return view
    }()
    
    var action:(() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setOpacityView()
        view.addSubview(contentView)
        let horizontalPadding:CGFloat = 35
        let verticalPadding:CGFloat = 217
        contentView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding))
        contentView.addSubview(closeButton)
        closeButton.anchor(top: contentView.topAnchor, leading: nil, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 20, left: 0, bottom: 0, right: 20),size: .init(width: 30, height: 30))
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        configureExitButton()
    }
    
    
    
    @objc private func didTapDone(){
        if let action = action {
            dismiss(animated: true,completion: action)
        } else {
            print("Post action is  not set")
        }
    }
    
    
    @objc private func didTapClose(){
        dismiss(animated: true)
    }
    
    
    private func addGesture(_ view:UIView){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func didTapView(){
        dismiss(animated: true)
    }
    
    // MARK: - custom effect
    
    fileprivate func configureExitButton() {
        let imageView = UIImageView(image: UIImage(systemName: "xmark.circle"))
        let padding:CGFloat = 1
        closeButton.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.anchor(top: closeButton.topAnchor, leading: closeButton.leadingAnchor, bottom: closeButton.bottomAnchor, trailing: closeButton.trailingAnchor,padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        imageView.tintColor = .darkSecondaryColor
    }
    
    
    private func setOpacityView(alpha:CGFloat = 0.7){
        let backGroundView = UIView()
        backGroundView.frame = view.bounds
        backGroundView.backgroundColor = .black.withAlphaComponent(alpha)
        view.addSubview(backGroundView)
        addGesture(backGroundView)
    }
    
    
    private func addBlurEffect(){
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        addGesture(blurEffectView)
    }
    
    private func setupNavBar() -> UINavigationBar {
        let navBar = UINavigationBar(frame: .zero)
        contentView.addSubview(navBar)
        navBar.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,size: CGSize(width: 0, height: 44))
        
        
        let navItem = UINavigationItem()
        let postButton = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(didTapDone))
        postButton.tintColor = .label
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: #selector(didTapClose))
        
//        navItem.leftBarButtonItem = closeButton
        navItem.rightBarButtonItem = closeButton
        navItem.titleView?.backgroundColor = .clear
        
        navBar.setItems([navItem], animated: false)
        return navBar
    }
    
}
