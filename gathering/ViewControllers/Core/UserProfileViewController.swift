//
//  UserProfileViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-08.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    // MARK: - Components
    
    private var collectionView:UICollectionView?
    
    
    // MARK: - Class members
    
    private let user:User
    
    private var userEvents:[UserEvent] = [] {
        didSet{
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Init
    init(user:User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        RealmManager.shared.fetchUserFromFirestore(userId: user.username)
        navigationItem.title = "Profile"
        setupCollectionView()
        fetchData()
    }
    
    
    private func fetchData() {
        DatabaseManager.shared.getUserEvents(username: user.username) { [weak self] userEvents in
            guard let userEvents = userEvents else {return}
            
            let sortedEvents = userEvents.compactMap({$0.endDateTimeStamp > Date().timeIntervalSince1970 ? $0 : nil}).sorted(by: {$0.startDateTimestamp > $1.startDateTimestamp})
            
            self?.userEvents = sortedEvents
        }
    }
}


extension UserProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    // MARK: - configure CollectionView
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: view.width, height: 50)
        layout.headerReferenceSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .init(top: 0, left: 0, bottom: 1, right: 0)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserEventCell.self, forCellWithReuseIdentifier: UserEventCell.identifier)
        collectionView.register(UserProfileHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderReusableView.identifier)
        
        self.collectionView = collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return userEvents.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserProfileHeaderReusableView.identifier, for: indexPath) as! UserProfileHeaderReusableView
            view.user = self.user
            view.delegate = self
            return view
        }else {
            return UICollectionReusableView()
        }
        
        

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {return CGSize(width: view.width, height: 250)}
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = userEvents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserEventCell.identifier, for: indexPath) as! UserEventCell
        cell.userEvent = model
        cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = userEvents[indexPath.row]
        
        guard let referencePath = model.referencePath else {return}
        
        let vc = EventDetailViewController()
        vc.configureWithID(eventID: model.id, eventReferencePath: referencePath)
        vc.configureCloseButton()
        
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.hero.isEnabled = true
        navVC.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
        
        present(navVC, animated: true)
        
    }
    
}


extension UserProfileViewController:ProfileHeaderReusableViewDelegate {
    // MARK: - Handle Follow
    func ProfileHeaderDelegateDidTapFollowBUtton(_ header: UICollectionReusableView, user: User) {
    }
    
    // MARK: - Handle send Message
    func ProfileHeaderReusableViewDelegatedidTapMessage(_ header: UICollectionReusableView, user: User) {
        let vc = ChatMessageViewController(targetUsername: user.username)
        vc.setupNavBar()
        
        vc.setUpPanBackGestureAndBackButton()
        presentModallyWithHero(vc)
        
        
    }
    
}
