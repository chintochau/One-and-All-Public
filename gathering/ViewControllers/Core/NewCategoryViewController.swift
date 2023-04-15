//
//  NewCategoryViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-24.
//

import UIKit


enum categoryType:String,CaseIterable {
    case post = "組團"
    case formEvent = "刊登活動"
//    case newEvent = "Post an Event"
//    case newGroup = "Create a new Group"
}



class NewCategoryViewController: UIViewController {
    
    private let viewModels = categoryType.allCases.map{$0}
    
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .init(top: 10, left:10, bottom: 0, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.register(PhotoLabelCollectionViewCell.self, forCellWithReuseIdentifier: PhotoLabelCollectionViewCell.identifier)
        return view
    }()

    
    private let loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "New Event"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AuthManager.shared.isSignedIn {
            configureCategoryView()
        }else {
            configureLoginView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if AuthManager.shared.isSignedIn {
            layoutCategoryView()
        }else {
            loginView.frame = view.safeAreaLayoutGuide.layoutFrame
        }
    }
    
    private func configureCategoryView(){
        loginView.removeFromSuperview()
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    private func layoutCategoryView(){
        collectionView.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
}

extension NewCategoryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoLabelCollectionViewCell.identifier, for: indexPath) as! PhotoLabelCollectionViewCell
        
        let vm = viewModels[indexPath.row]
        switch vm {
        case .post:
            cell.configure(withImage: UIImage(named: "form.event"), text: vm.rawValue)
        case .formEvent:
            cell.configure(withImage: UIImage(named: "post.event"), text: vm.rawValue)
//        case .newEvent:
//            cell.configure(withImage: UIImage(named: "post.event"), text: vm.rawValue)
        default:
            cell.configure(withImage: UIImage(named: "create.group"), text: vm.rawValue)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageSize:CGFloat = (view.height/2.6)
        return CGSize(width: imageSize, height: imageSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let user = DefaultsManager.shared.getCurrentUser(),
           let _ = user.name,
           let _ = user.gender{
            
            let vm = viewModels[indexPath.row]
            switch vm {
            case .post:
                let vc = NewPostViewController()
                vc.completion = { [weak self] post, images in
                    guard let post = post else {return}
                    let vc = EventDetailViewController()
                    let vm = EventCellViewModel(event: post)
                    
                    print("images need configure")
                    
                    vc.viewModel = vm
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                navigationController?.pushViewController(vc, animated: true)
            case .formEvent:
                let vc = CreateNewEventViewController()
                vc.completion = { [weak self] event, image in
                    let vc = EventDetailViewController()
                    let vm = EventCellViewModel(event: event)
                    vm.image = image
                    vc.viewModel = vm
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                navigationController?.pushViewController(vc, animated: true)
                
//            case .newEvent:
//                let vc = NewEventViewController()
//                vc.completion = { [weak self] event,image in
//                    let vc = EventViewController(viewModel: EventViewModel(with: event, image: image)!)
//                    self?.navigationController?.pushViewController(vc, animated: true)
//                }
//                navigationController?.pushViewController(vc, animated: true)
            default:
                print("Not yet implemented")
            }
            
        }else {
            guard let user = DefaultsManager.shared.getCurrentUser() else {return}
            let vc = EditProfileViewController(user: user)
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC, animated: true)
        }
        
        
        
    }
    
    // MARK: - Highlight animation
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5){
            if let cell = collectionView.cellForItem(at: indexPath) as? PhotoLabelCollectionViewCell {
                cell.imageView.transform = .init(scaleX: 1.1, y: 1.1)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            if let cell = collectionView.cellForItem(at: indexPath) as? PhotoLabelCollectionViewCell {
                cell.imageView.transform = .identity
            }
        }
    }
    
}

extension NewCategoryViewController:LoginViewDelegate {
    
    
    func didTapPrivacy() {
        let vc = PolicyViewController(title: "Privacy Policy", policyString: Policy.privacyPolicy)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    func didTapTerms() {
        let vc = PolicyViewController(title: "Terms", policyString: Policy.terms)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    
    
    func didTapLogin(_ view: LoginView, email: String, password: String) {
        AuthManager.shared.logIn(email: email, password: password) { [weak self] user in
            
            view.indicator.stopAnimating()
            view.loginButton.isHidden = false
            
            guard user != nil else {
                print("Failed to retrive user data")
                return
            }
            
            self?.loginView.removeFromSuperview()
            self?.configureCategoryView()
            
            CustomNotificationManager.shared.requestForNotification()
        }
    }
    
    private func configureLoginView() {
        loginView.configureTitle(text: "Login to create new event")
        view.addSubview(loginView)
        loginView.delegate = self
        loginView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        present(UINavigationController(rootViewController: vc),animated: true)
    }
    
}
