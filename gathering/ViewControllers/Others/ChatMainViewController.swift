//
//  ChatMainViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-17.
//

import UIKit
import PubNub
import RealmSwift
import SwipeCellKit

class ChatMainViewController: UIViewController {
    
    // MARK: - Components
    private let tableView:UITableView = {
        let view = UITableView()
        view.backgroundColor = .systemBackground
        view.register(ChatConversationTableViewCell.self, forCellReuseIdentifier: ChatConversationTableViewCell.identifier)
        return view
    }()
    
    private let signinMessage:UILabel = {
        let view = UILabel()
        view.text = "登入以傳送訊息給好友"
        view.textColor = .label
        return view
    }()
    
    private let loginButton:UIButton = {
        let view = UIButton()
        
        
        return view
    }()
    
    // MARK: - Class members
    
    private let pubnub = ChatMessageManager.shared.pubnub
    private var conversations:Results<ConversationObject>?
    
    var notificationToken:NotificationToken?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(signinMessage)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.fillSuperview()
        observeConversationsFromRealm()
        
        signinMessage.isHidden = AuthManager.shared.isSignedIn
        signinMessage.sizeToFit()
        signinMessage.center = view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        
    }
    
    
    
    deinit {
        notificationToken?.invalidate()
    }
    
    private func observeConversationsFromRealm() {
        let realm = try! Realm()
        let results = realm.objects(ConversationObject.self)
        notificationToken = results.observe({ [weak self] changes in
            guard let self = self else {return}
            switch changes {
            case .initial(_):
                self.tableView.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                // Subsequent notification blocks will return .update, which is where you can update the UI to reflect changes to the MyObject instance
                print("Collection state has changed:")
                print("Deletions: \(deletions)")
                print("Insertions: \(insertions)")
                print("Modifications: \(modifications)")
                self.tableView.reloadData()
            case .error(let error):
                print("Error observing Realm changes: \(error.localizedDescription)")
            }
        })
        
        conversations = results.sorted(byKeyPath: "lastUpdated", ascending: false)
    }
    
    private func setupNavBar(){
        navigationItem.title = "訊息"
        navigationController?.navigationBar.tintColor = .label
        
        if AuthManager.shared.isSignedIn {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(didTapNewMessage))
            
        }else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapNewMessage(){
        let vc = ChatListViewController()
        vc.setUpPanBackGestureAndBackButton()
        vc.completion = { [weak self] targetUsername in
            let vc = ChatMessageViewController(targetUsername: targetUsername)
            vc.setUpPanBackGestureAndBackButton()
            self?.presentModallyWithHero(vc)
        }
        presentModallyWithHero(vc)
        
    }
    
    
    private func deleteChat(with targetUsername:String){
        let realm = try! Realm()
        
        let channelId = IdManager.shared.generateChannelIDFor(targetUsername: targetUsername)
        
        if let object = RealmManager.shared.getObject(ofType: ConversationObject.self, forPrimaryKey: channelId) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }
}

extension ChatMainViewController:UITableViewDataSource,UITableViewDelegate,SwipeTableViewCellDelegate {
    
    
    
    // MARK: - Delegate + DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = conversations?[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatMessageViewController(targetUsername: model?.targetname ?? "")
        vc.setUpPanBackGestureAndBackButton()
        presentModallyWithHero(vc)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatConversationTableViewCell.identifier, for: indexPath) as! ChatConversationTableViewCell
        cell.conversation = model
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "刪除") { [weak self] action, indexPath in
            
            guard let self = self else {return}
            let conversation = self.conversations?[indexPath.row]
            AlertManager.shared.showAlert(title: "刪除", message: "確定要刪除此聊天嗎？刪除後將無法恢復。",buttonText: "刪除", buttonStyle: .destructive, from: self) {
                self.deleteChat(with: conversation?.targetname ?? "")
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> SwipeCellKit.SwipeOptions {
        return .init()
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeCellKit.SwipeActionsOrientation) {
        
    }
    
    func visibleRect(for tableView: UITableView) -> CGRect? {
        nil
    }
    
    
    
}
