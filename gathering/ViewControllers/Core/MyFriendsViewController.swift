//
//  MyFriendsViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-23.
//

import UIKit


class MyFriendsViewController: UIViewController {
    
    var favouritedItems = DefaultsManager.shared.getFavouritedEvents()
    
    private var titles:[String] = {
        return [favouriteType.allCases.last?.rawValue ?? ""]
    }()
    
    
    
    lazy var segmentedButtonsView:MenuBar = {
        let view = MenuBar()
        var array = titles
        view.items = array
        return view
    }()
    
    
    private let signinMessage:UILabel = {
        let view = UILabel()
        view.text = "登入以添加朋友"
        view.textColor = .label
        return view
    }()
    
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view  = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(FriendsTableCollectionViewCell.self, forCellWithReuseIdentifier: FriendsTableCollectionViewCell.identifier)
        view.register(EventsTableCollectionViewCell.self, forCellWithReuseIdentifier: EventsTableCollectionViewCell.identifier)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [collectionView,signinMessage].forEach({view.addSubview($0)})
        
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        segmentedButtonsView.delegate = self
        
        //        segmentedButtonsView.delegate = self
        let navView = UIView()
        navView.addSubview(segmentedButtonsView)
        navigationItem.titleView = navView
        segmentedButtonsView.frame = CGRect(x: 0, y: 0, width: view.width, height: 35)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        
        
        signinMessage.sizeToFit()
        signinMessage.frame = CGRect(x: 0, y: 0, width: signinMessage.width, height: signinMessage.height)
        signinMessage.center = view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        signinMessage.isHidden = AuthManager.shared.isSignedIn
        
    }
    
}

extension MyFriendsViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MenuBarDelegate {
    func MenuBarDidTapItem(_ menu: MenuBar, menuIndex: Int) {
        collectionView.scrollToItem(at: .init(row: menuIndex, section: 0), at: [], animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsTableCollectionViewCell.identifier, for: indexPath) as! FriendsTableCollectionViewCell
            cell.delegate = self
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventsTableCollectionViewCell.identifier, for: indexPath) as! EventsTableCollectionViewCell
            cell.viewController = self
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsTableCollectionViewCell.identifier, for: indexPath) as! FriendsTableCollectionViewCell
            cell.delegate = self
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        segmentedButtonsView.collectionViewDidScroll(for: scrollView.contentOffset.x / CGFloat(titles.count))
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x/view.frame.width
        segmentedButtonsView.collectionView.selectItem(at: .init(row: Int(index), section: 0), animated: false, scrollPosition: [])
    }
    
}

extension MyFriendsViewController:FriendsCollectionViewCellDelegate {
    func FriendsCollectionViewCellDidSelectFriend(_ cell: FriendsTableCollectionViewCell, result: Any) {
        guard let username = result as? String else {return}
        
        if let userObject = RealmManager.shared.getObject(ofType: UserObject.self, forPrimaryKey: username) {
            let vc = UserProfileViewController(user: userObject.toUser())
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MyFriendsViewController:SegmentedControlDelegate {
    
    func didIndexChanged(at index: Int) {
        if index == 0 {
            // scroll forward
            let collectionBounds = collectionView.bounds
            let contentOffset = CGFloat(floor(collectionView.contentOffset.x - collectionBounds.size.width))
            moveToFrame(contentOffset: contentOffset)
            
        }else if index == 1 {
            // scroll backward
            let collectionBounds = collectionView.bounds
            let contentOffset = CGFloat(floor(collectionView.contentOffset.x + collectionBounds.size.width))
            moveToFrame(contentOffset: contentOffset)
        }
        
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        
        let frame: CGRect = CGRect(x : contentOffset ,y : collectionView.contentOffset.y ,width : self.collectionView.frame.width,height : collectionView.frame.height)
        
        self.collectionView.scrollRectToVisible(frame, animated: true)
    }
    
    
}
