//
//  CategoryViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-02.
//

import UIKit

class CategoryViewController: CustomModalViewController {
    
    let iconImage:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named:  "petIcon")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let messageLabel:UILabel = {
        let view = UILabel()
        view.text = "你想做啲咩？"
        return view
    }()
    
    private let firstButton:GradianBorderButton = {
        let view = GradianBorderButton()
        view.titleString = "組團"
        view.subString = "您想搵到志同道合嘅人一齊活動"
        return view
    }()
    
    private let secondButton:GradianBorderButton = {
        let view = GradianBorderButton()
        view.titleString = "刊登活動"
        view.subString = "你想同大家分享一啲正嘅活動"
        return view
    }()
    
    var firstAction: (() -> Void)?
    var secondAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [messageLabel,firstButton].forEach({view.addSubview($0)})
        
        contentView.addSubview(iconImage)
        iconImage.anchor(top: contentView.topAnchor, leading: nil, bottom: nil, trailing: nil,padding: .init(top: 30, left: 0, bottom: 0, right: 0),size: .init(width: 0, height: 94))
        iconImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        messageLabel.anchor(top: iconImage.bottomAnchor, leading:nil , bottom: nil, trailing: nil)
        messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        firstButton.anchor(top: messageLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil,padding: .init(top: 40, left: 0, bottom: 0, right: 0),size: .init(width: 254, height: 80))
        firstButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //        secondButton.anchor(top: firstButton.bottomAnchor, leading: nil, bottom: nil, trailing: nil,padding: .init(top: 20, left: 0, bottom: 0, right: 0),size: .init(width: 254, height: 80))
        //        secondButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //
        
        firstButton.setupTapGesture {[weak self] in
            self?.firstAction?()
        }
        
        //        secondButton.setupTapGesture {[weak self] in
        //            self?.secondAction?()
        //        }
    }
    
    
    
}


extension UIViewController {
    
    func showCategoryViewController(){
        
        let vc = CategoryViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        vc.firstAction = {[weak self] in
            self?.dismiss(animated: false)
            self?.showNewPostViewController()
        }
        
        present(vc, animated: true)
        
    }
    
    
    
    func showNewPostViewController (eventName:String = "") {
        
        if !AuthManager.shared.isSignedIn {
            dismiss(animated: false)
            AlertManager.shared.showAlert(title: "Oops~", message: "登入後便可建立活動", from: self)
            return
        }
        
        
        let vc = NewPostViewController()
        vc.newPost.title = eventName
        
        
        vc.completion = { [weak self] post, images in
            guard let post = post else {return}
            
            self?.dismiss(animated: false)
            
            let vc = EventDetailViewController()
            
            let vm = EventCellViewModel(event: post)
            
            if !images.isEmpty {
                print("images need modify")
            }
            
            vc.viewModel = vm
            self?.presentModallyWithHero(vc)
        }
        
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        navVc.navigationBar.tintColor = .label
        present(navVc, animated: true)
    }
    
    
    func showCreateNewevent () {
        if !AuthManager.shared.isSignedIn {
            dismiss(animated: false)
            AlertManager.shared.showAlert(title: "Oops~", message: "登入後便可建立活動", from: self)
            return
        }
        dismiss(animated: false)
        let vc = CreateNewEventViewController()
        vc.completion = { [weak self] event, image in
            let vc = EventDetailViewController()
            let vm = EventCellViewModel(event: event)
            vm.image = image
            
            vc.viewModel = vm
            
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
}
