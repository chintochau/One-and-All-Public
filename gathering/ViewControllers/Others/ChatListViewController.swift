//
//  ChatListViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-21.
//

import UIKit

class ChatListViewController: UIViewController {
    
    private let friends:[UserObject] = RelationshipManager.shared.getFriendsInUserObjects()
    private var filteredList = [UserObject]()
    
    private let tableView:UITableView = {
        let view = UITableView()
        view.backgroundColor = .systemBackground
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return view
    }()
    
    private let searchBar:UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "搜尋朋友"
        return view
    }()
    
    /// return how many friends are invited
    var completion: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "新訊息"
        setUpPanBackGestureAndBackButton()
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        filteredList = friends
        view.backgroundColor = .systemBackground
        [searchBar,tableView].forEach({view.addSubview($0)})
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        tableView.anchor(top: searchBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    
}

extension ChatListViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserTableViewCell()
        cell.configure(with: filteredList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUsername = friends[indexPath.row].username
        self.dismiss(animated: false) {[weak self] in
            self?.completion?(targetUsername)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    
}

extension ChatListViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredList = friends
        } else {
            filteredList = friends.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredList = friends
        tableView.reloadData()
    }
}
