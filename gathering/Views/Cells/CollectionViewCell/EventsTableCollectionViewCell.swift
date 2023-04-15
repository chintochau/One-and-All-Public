//
//  EventsTableCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-09.
//


import UIKit
import RealmSwift

protocol EventsTableCollectionViewCellDelegate:AnyObject {
    func EventsTableCollectionViewCellDidTapResult(_ cell:EventsTableCollectionViewCell, result:Any)
}

class EventsTableCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EventsTableCollectionViewCell"
    
    weak var delegate:EventsTableCollectionViewCellDelegate?
    
    var viewController:UIViewController?
    
    private lazy var refresheControl:UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return view
    }()
    
    // MARK: - Components
    
    let refreshControl = UIRefreshControl()
    
    var collectionView:UICollectionView?
    
    var userEvents:[UserEvent] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: - Class members
    
    var favType:String?{
        didSet{
            switch favType {
            case favouriteType.events.rawValue:
                break
                
            case favouriteType.users.rawValue:
                break
                
            default :
                print("Not yet implemented")
            }
            collectionView?.reloadData()
        }
        
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: width, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        [collectionView].forEach({addSubview($0)})
        collectionView.refreshControl = refreshControl
        collectionView.fillSuperview()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.register(UserEventCell.self, forCellWithReuseIdentifier: UserEventCell.identifier)
        self.collectionView = collectionView
        
        fetchData {
            
        }
    }
    
    
    fileprivate func fetchData(completion:@escaping() -> Void) {
        guard let username = DefaultsManager.shared.getCurrentUser()?.username else {return}
        DatabaseManager.shared.getUserEvents(username: username) { [weak self] userEvents in
            let outputEvents = userEvents?.compactMap({ userevent in
                return userevent.endDateTimeStamp > Date().timeIntervalSince1970 ? userevent : nil
            })
            self?.userEvents = outputEvents?.sorted(by: {$0.startDateTimestamp > $1.startDateTimestamp}) ?? []
            completion()
        }
    }
    
    
    @objc private func didPullToRefresh(){
        fetchData {[weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
}

extension EventsTableCollectionViewCell:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vm = userEvents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserEventCell.identifier, for: indexPath) as! UserEventCell
        cell.userEvent = vm
        cell.widthAnchor.constraint(equalToConstant: width).isActive = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vm = userEvents[indexPath.row]
        if let referencePath = vm.referencePath {
            viewController?.presentEventDetailViewController(eventID: vm.id, eventRef: referencePath)
        }
    }
    
}
