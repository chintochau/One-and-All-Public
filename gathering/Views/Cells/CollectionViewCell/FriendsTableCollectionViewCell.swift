//
//  ResultTableCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-10.
//

import UIKit
import RealmSwift

protocol FriendsCollectionViewCellDelegate:AnyObject {
    func FriendsCollectionViewCellDidSelectFriend(_ cell:FriendsTableCollectionViewCell, result:Any)
}

class FriendsTableCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FriendsTableCollectionViewCell"
    
    weak var delegate:FriendsCollectionViewCellDelegate?
    
    // MARK: - Components
    
    let refreshControl = UIRefreshControl()
    
    let tableView:UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.keyboardDismissMode = .interactive
        view.alwaysBounceVertical = true
        
        return view
    }()
    
    private let searchBar:UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Search"
        return view
    }()
    
    private var notificationToken: NotificationToken?
    
    
    // MARK: - Class members
    private var relationships:Results<RelationshipObject>
    private var searchResults:[RelationshipObject] = []
    
    
    override init(frame: CGRect) {
        let realm = try! Realm()
        relationships = realm.objects(RelationshipObject.self)
        
        
        super.init(frame: frame)
        [searchBar,tableView].forEach({addSubview($0)})
        
        searchBar.frame = CGRect(x: 0, y: top, width: width, height: 56)
        searchBar.delegate = self
        
        tableView.frame = CGRect(x: 0, y: searchBar.bottom, width: width, height: height-searchBar.bottom)
        
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.register(FriendTableViewCell.self, forCellReuseIdentifier: FriendTableViewCell.identifier)
        
        notificationToken = relationships.observe {[weak self] change in
            switch change {
                
            case .initial(_):
                print("initial")
            case .update(_, deletions: _, insertions: _, modifications: _):
                // Query results have changed, so apply them to the TableView
                self?.tableView.reloadData()
            case .error(_):
                print("error ")
            }
        }
        
        
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        searchResults.removeAll()
    }
    
    @objc private func didPullToRefresh(){
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension FriendsTableCollectionViewCell:UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "targetUsername CONTAINS[c] %@", searchText)
        let results = realm.objects(RelationshipObject.self).filter(predicate)
        searchResults = Array(results)
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResults.removeAll()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
}

extension FriendsTableCollectionViewCell:UITableViewDelegate,UITableViewDataSource, FriendTableViewCellDelegate {
    
    func FriendTableViewCellDidTapFollow(_ cell: FriendTableViewCell) {
        // Already handled within the cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        getResults().count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = getResults()[indexPath.row]
        
        let cell = FriendTableViewCell(username: model.targetUsername)
        cell.relationship = model
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        if let cell = tableView.cellForRow(at: indexPath) as? FriendTableViewCell {
            cell.updateUserProfile()
        }
        
        
        let model = getResults()[indexPath.row]
        
        delegate?.FriendsCollectionViewCellDidSelectFriend(self, result: model.targetUsername)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func getResults() -> [RelationshipObject] {
        
        
        
        if !searchResults.isEmpty {
            return searchResults.sorted(by: {$0.status > $1.status})
        } else if searchBar.text != "" {
            return []
        }else {
            return relationships.sorted(by: {$0.status > $1.status})
        }
    }
}
