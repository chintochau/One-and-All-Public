//
//  TabBarViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-11.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    
    let extraButton = GradientButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.tabBar.tintColor = .darkMainColor
        self.tabBar.isTranslucent = true// Set the background color with alpha
        self.tabBar.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        
        //Define VC
        let home = NewHomeViewController()
        let myEvents = MyEventsViewController()
        let myFriends = MyFriendsViewController()
        let messages = ChatMainViewController()
        let profile = ProfileViewController()
        
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: myEvents)
        let nav3 = UINavigationController(rootViewController: myFriends)
        let nav4 = UINavigationController(rootViewController: messages)
        let nav5 = UINavigationController(rootViewController: profile)
        
        // Define tab items
        
        nav1.tabBarItem = UITabBarItem(title: "發現", image: UIImage(systemName: "globe"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "活動", image: UIImage(systemName: "calendar" ), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "連繫", image: UIImage(systemName: "person.2.square.stack" ), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "訊息", image: UIImage(systemName: "bubble.left" ), tag: 4)
        nav5.tabBarItem = UITabBarItem(title: "個人", image: UIImage(systemName: "person.circle" ), tag: 5)
        
        if #available(iOS 14.0, *) {
            home.navigationItem.backButtonDisplayMode = .minimal
            myEvents.navigationItem.backButtonDisplayMode = .minimal
            myFriends.navigationItem.backButtonDisplayMode = .minimal
            messages.navigationItem.backButtonDisplayMode = .minimal
            profile.navigationItem.backButtonDisplayMode = .minimal
        } else {
            // Fallback on earlier versions
        }
        
        
        [nav1,nav2,nav3,nav4,nav5].forEach({
            $0.navigationBar.tintColor = .label
            $0.navigationBar.prefersLargeTitles = false
        })
        
        if #available(iOS 14.0, *) {
            nav3.navigationItem.backButtonDisplayMode = .minimal
        } else {
            // Fallback on earlier versions
            nav3.navigationItem.backButtonTitle = ""
        }
        
        // set controllers
        self.setViewControllers([
            nav1,
            nav2,
            nav3,
            nav4,
            nav5
        ], animated: false)
        
        appInitialListener()
    }
    
    
    public func hideTabBar(){
        tabBar.isHidden = true
        extraButton.isHidden = true
    }
    
    public func showTabBar() {
        tabBar.isHidden = false
        extraButton.isHidden = false
    }
    
    private func addExtraButton(){
        // Set up the extra button
        let buttonSize:CGFloat = 60
        extraButton.frame = CGRect(x: (view.bounds.width - buttonSize) / 2, y: view.height-tabBar.height-buttonSize, width: buttonSize, height: buttonSize)
        extraButton.layer.cornerRadius = 20
        extraButton.setGradient(colors: [.lightMainColor,.darkSecondaryColor], startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 1),image: UIImage(systemName: "plus"))
        extraButton.addTarget(self, action: #selector(didSelectTap(_:)), for: .touchUpInside)
        view.addSubview(extraButton)
        
    }
    
    @objc private func didSelectTap(_ sender:UIButton) {
        selectedIndex = 1
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // Check if the second tab (index 1) is clicked
        
        if let viewController = viewController as? UINavigationController {
            if viewController.topViewController is NewCategoryViewController {
                let vc = CategoryViewController()
                
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                
                vc.firstAction = {[weak self] in
                    self?.openCreateNewPost()
                }
                
                vc.secondAction = {[weak self] in
                    self?.openCreateNewEvent()
                }
                
                
                present(vc, animated: true)
                return false
            }
        }
        
        return true
    }
    
    private func openCreateNewPost () {
        
        if !AuthManager.shared.isSignedIn {
            dismiss(animated: false)
            AlertManager.shared.showAlert(title: "Oops~", message: "登入後便可建立活動", from: self)
            return
        }
        
        dismiss(animated: false)
        
        let vc = NewPostViewController()
        
        vc.completion = { [weak self] post, images in
            
            guard let post = post else {return}
            
            self?.dismiss(animated: false)
            
            let vc = EventDetailViewController()
            
            let vm = EventCellViewModel(event: post)
            
            if !images.isEmpty {
                print("images need modify")
            }
            
            vc.viewModel = vm
            
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.hero.isEnabled = true
            navVC.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
            navVC.navigationBar.tintColor = .label
            
            if let firstTab = self?.viewControllers?.first as? UINavigationController {
                
                firstTab.present(navVC, animated: true)
            }
            
        }
        present(vc, animated: true)
    }
    
    
    private func openCreateNewEvent () {
        if !AuthManager.shared.isSignedIn {
            dismiss(animated: false)
            AlertManager.shared.showAlert(title: "Oops~", message: "登入後便可建立活動", from: self)
            selectedIndex = 2
            return
        }
        dismiss(animated: false)
        let vc = CreateNewEventViewController()
        vc.completion = { [weak self] event, image in
            let vc = EventDetailViewController()
            let vm = EventCellViewModel(event: event)
            vm.image = image
            
            vc.viewModel = vm
            
            if let firstTab = self?.viewControllers?.first as? UINavigationController {
                firstTab.pushViewController(vc, animated: true)
            }else {
                let navVc = UINavigationController(rootViewController: vc)
                navVc.modalPresentationStyle = .fullScreen
                navVc.navigationBar.tintColor = .label
                self?.present(navVc, animated: true)
                
            }
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    // MARK: - Initial Listener
    
    fileprivate func appInitialListener() {
        guard let _ = UserDefaults.standard.string(forKey: "username") else {return}
        ChatMessageManager.shared.connectToChatServer(true)
        RelationshipManager.shared.observeFirebaseRelationshipsChangesIntoRealm()
        //        DummyDataManager.shared.generateDummyEvents()
        //        DummyDataManager.shared.createNotificationForEachUsers()
        //        DummyDataManager.shared.createDemoUsers()
        //        DatabaseManager.shared.addMentor()
//        DatabaseManager.shared.addOrganisation()
    }
    
}
