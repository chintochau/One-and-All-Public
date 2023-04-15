//
//  ChatViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-17.
//


import UIKit
import RealmSwift
import Hero

struct ChatMessage {
    let text:String
    let isIncoming:Bool
}

class ChatMessageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Components
    
    let tableView:UITableView = {
        let view = UITableView()
        view.backgroundColor = .systemBackground
        view.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: ChatMessageTableViewCell.identifier)
        view.keyboardDismissMode = .interactive
        view.separatorStyle = .none
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    let textView:UITextView = {
        let view = UITextView()
        view.backgroundColor = .secondarySystemBackground
        view.font = .preferredFont(forTextStyle: .body)
        view.layer.cornerRadius = 5
        return view
    }()
    
    let sendButton:UIButton = {
        let view = UIButton()
        view.setTitle("Send", for: .normal)
        view.setTitleColor(.link, for: .normal)
        return view
    }()
    
    // MARK: - Class members
    
    let maxNumberOfLines = 5
    let targetUsername:String
    var textViewBottomConstraint: NSLayoutConstraint?
    var conversation:ConversationObject
    var messages: Results<MessageObject>
    var notificationToken:NotificationToken?
    
    // MARK: - Init
    
    init(targetUsername:String) {
        self.targetUsername = targetUsername
        self.conversation = ChatMessageManager.shared.getInitialConversationWithUsername(targetUsername: targetUsername)!
        self.messages = conversation.messages.sorted(byKeyPath: "sentDate")
        
        RealtimeDatabaseManager.shared.getOrCreatePrivateChannel(targetUsername: targetUsername) { channelId in
            print("ChatMessageViewCon\(channelId)")
        }
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = targetUsername
        observeConversationsFromRealm()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        [textView,sendButton,tableView].forEach({view.addSubview($0)})
        setupTableView()
        setupInputComponent()
        registerKeyboardNotifications()
        ChatMessageManager.shared.listenToChannel(targetUsername: targetUsername)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        // Customize the gesture recognizer to work with Hero transitions
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        for recognizer in self.view.gestureRecognizers ?? [] {
            recognizer.delegate = self
        }
        
        
        
        
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            return !Hero.shared.transitioning && navigationController.value(forKey: "_isTransitioning") as? Bool != true
        }
        return false
    }

    
    func setupNavBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(didTapGoBack))
    }
    
    
    @objc private func didTapGoBack (){
        self.dismiss(animated: true)
    }
    
    
    fileprivate func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    fileprivate func registerKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupInputComponent(){
        
        sendButton.anchor(top: nil, leading: nil, bottom: textView.bottomAnchor, trailing: view.trailingAnchor,size: CGSize(width: 80, height: 0))
        
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        textView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: sendButton.leadingAnchor,padding: .init(top: 0, left: 5, bottom: 0, right: 5))
        
        textView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: 10)
        textViewBottomConstraint?.isActive = true
        
        textView.delegate = self
        
    }
    
    private func scrollToBottom(animated:Bool = true) {
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        if lastRow >= 0 {
            let lastIndexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            textViewBottomConstraint?.constant = -keyboardSize.height + 10
            DispatchQueue.main.async {
                self.scrollToBottom()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textViewBottomConstraint?.constant = 10
    }
    
    
    // MARK: - Handle Send Message
    @objc private func didTapSend(){
        
        
        if let text = textView.text {
            
            guard let user = DefaultsManager.shared.getCurrentUser() else {return}
            
            let message = MessageObject()
            message.text = "text message"
            message.sender = user.realmObject()
            message.channelId = IdManager.shared.generateChannelIDFor(targetUsername: targetUsername)
            
            RealtimeDatabaseManager.shared.sendMessage(message)
            
            
            ChatMessageManager.shared.sendMessageToUser(targetUsername: targetUsername, text: text)
            textView.text = nil
        }
    }
    
    // MARK: - Observe Message changes
    private func observeConversationsFromRealm() {
        
        notificationToken = messages.observe({ [weak self] changes in
            guard let self = self else {return}
            switch changes {
            case .initial(_):
                self.tableView.reloadData()
                self.scrollToBottom(animated: false)
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                // Subsequent notification blocks will return .update, which is where you can update the UI to reflect changes to the MyObject instance
                self.tableView.reloadData()
                self.scrollToBottom(animated: false)
            case .error(let error):
                print("Error observing Realm changes: \(error.localizedDescription)")
            }
        })
        
    }
}



extension ChatMessageViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = conversation.messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageTableViewCell.identifier, for: indexPath) as! ChatMessageTableViewCell
        cell.chatMessage = message
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension ChatMessageViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        let lineHeight = textView.font?.lineHeight ?? 0
        let numberOfLines = Int(estimatedSize.height / lineHeight)
        if numberOfLines > maxNumberOfLines {
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
            textView.constraints.forEach { [weak self] constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                    if let scrollView = self?.tableView {
                        if(scrollView.contentSize.height - scrollView.frame.height - scrollView.contentOffset.y < 100) {
                            self?.scrollToBottom(animated: false)
                        }
                    }
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}


