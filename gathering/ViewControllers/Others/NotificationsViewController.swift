//
//  NotificationsViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-14.
//

import UIKit

class NotificationsViewController: CollectionListViewController {
    
    static let shared = NotificationsViewController()
    
    private lazy var refreshControler:UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotifications()
        navigationItem.title = "通知"
        
        collectionView.register(NotificationCollectionViewCell.self, forCellWithReuseIdentifier: NotificationCollectionViewCell.identifier)
        collectionView.refreshControl = refreshControler
    }
    
    private func fetchNotifications(){
        CustomNotificationManager.shared.fetchNotifications(lastNotificationDate: Date().timeIntervalSince1970) { notifications in
            self.items = notifications.sorted(by: {$0.createdAt > $1.createdAt})
            self.collectionView.reloadData()
            self.refreshControler.endRefreshing()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let item = items[indexPath.row] as? GANotification else {return UICollectionViewCell()}
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationCollectionViewCell.identifier, for: indexPath) as! NotificationCollectionViewCell
        cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
        cell.bindViewModel(item)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items[indexPath.row] as? GANotification else {return}
        
        switch item.type {
            
        case .friendRequest:
            guard let user = item.sentUser else {return}
            
            let vc = UserProfileViewController(user: user.toUser())
            vc.setUpPanBackGestureAndBackButton()
            presentModallyWithHero(vc)
            
            
        case .eventJoin:
            break
        case .eventInvite:
            guard let event = item.event, let ref = event.referencePath else {return}
            presentEventDetailViewController(eventID: event.id, eventRef: ref )
        case .eventUpdate:
            break
        case .friendAccept:
            break
        }
        
    }
    
    @objc private func didPullToRefresh(){
        fetchNotifications()
    }
    
}
