//
//  PreviewViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-03.
//

import UIKit



class PreviewViewController: UIViewController {
    
    private let contentView:UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.opaqueSeparator.cgColor
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        return view
    }()
    
    private let eventDetail:UITextView = {
        let view = UITextView()
        view.font = .preferredFont(forTextStyle: .body)
        view.isEditable = false
        return view
    }()
    
    var action:(() -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBlurEffect()
        view.addSubview(contentView)
        contentView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: view.height/5, left: 20, bottom: view.height/5, right: 20))
        contentView.addSubview(eventDetail)
        let navBar = setupNavBar()
        
        eventDetail.anchor(top: navBar.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 20, right: 20))
    }
    
    
    fileprivate func setupNavBar() -> UINavigationBar {
        let navBar = UINavigationBar(frame: .zero)
        contentView.addSubview(navBar)
        navBar.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,size: CGSize(width: 0, height: 44))
        
        let navItem = UINavigationItem(title: "Preview")
        let postButton = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(didTapDone))
        postButton.tintColor = .label
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: #selector(didTapClose))
        
        navItem.leftBarButtonItem = closeButton
        navItem.rightBarButtonItem = postButton
        
        navBar.setItems([navItem], animated: false)
        return navBar
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
    
    private func addBlurEffect(){
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        addGesture(blurEffectView)
    }
    
    @objc private func didTapView(){
        dismiss(animated: true)
    }
    
    func configure(with vm:PreviewViewModel) {
        eventDetail.text = vm.eventString
    }
    

}
