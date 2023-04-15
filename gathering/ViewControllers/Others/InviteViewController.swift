//
//  InviteViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-11.
//

import UIKit

class InviteViewController: UIViewController {
    
    private let friends:[UserObject] = RelationshipManager.shared.getFriendsInUserObjects()
    private var filteredList = [UserObject]()
    private var selectedFriends:[String] = []
    var joinedFriends:[String] = []
    var event:UserEvent?
    
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
    var completion: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "邀請朋友"
        setUpPanBackGestureAndBackButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "邀請", style: .plain, target: self, action: #selector(didTapInvite))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        filteredList = friends
        view.backgroundColor = .systemBackground
        [searchBar,tableView].forEach({view.addSubview($0)})
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        tableView.anchor(top: searchBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        searchBar.delegate = self
    }
    
    
    // MARK: - private func
    
    @objc private func didTapInvite(){
        AlertManager.shared.showAlert(title: "",message: "邀請\(selectedFriends.count)個朋友參加?", buttonText: "確定", from: self) {[weak self] in
            guard let user = DefaultsManager.shared.getCurrentUser(),
            let event = self?.event else {return}
            
            self?.selectedFriends.forEach({
                CustomNotificationManager.shared.sendNotificationToUser(
                    username: $0,
                    notification: .init(
                        id: IdManager.shared.createInviteId(targetUsername: $0, eventId: event.id) ,
                        type: .eventInvite,
                        sentUser: user.toSentUser(),
                        event: event))
            })
            self?.dismiss(animated: false)
            self?.completion?(self?.selectedFriends.count ?? 0)
            
        } cancelCompletion: {
            print("cancelled")
        }
    }

}

extension InviteViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserTableViewCell()
        cell.configure(with: filteredList[indexPath.row])
        
        let cellUsername = filteredList[indexPath.row].username
        
        if joinedFriends.contains(cellUsername) {
            cell.isUserInteractionEnabled = false
            cell.valuelabel.text = "已參加"
        } else if selectedFriends.contains(cellUsername) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredList[indexPath.row].username
        
        if !selectedFriends.contains(selectedUser) {
            selectedFriends.append(selectedUser)
            print(selectedFriends)
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = !selectedFriends.isEmpty
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedUser = filteredList[indexPath.row].username
        
        if let index = selectedFriends.firstIndex(of: deselectedUser) {
            selectedFriends.remove(at: index)
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = !selectedFriends.isEmpty
        tableView.reloadData()
    }
    
    
}

extension InviteViewController:UISearchBarDelegate {
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
