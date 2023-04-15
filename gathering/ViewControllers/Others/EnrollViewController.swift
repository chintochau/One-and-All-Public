//
//  EnrollViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-26.
//

import UIKit



struct EnrollViewModel {
    let currentUser:User
    let contacts:Contacts
    let eventTitle:String
    let dateString:String
    let startDate:Date
    let endDate:Date
    let location:String
    let eventID:String
    let event:Event
    
    init?(with event:Event) {
        guard let user = DefaultsManager.shared.getCurrentUser() else {return nil}
        self.currentUser = user
        self.event = event
        self.eventTitle = event.title
        self.dateString = event.getDateDetailString()
        self.location = event.location.name
        self.eventID = event.id
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.contacts = user.contacts ?? .init(instagram: nil, telegram: nil, phone: nil)
    }
}



class EnrollViewController: UIViewController {
    
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let nameField:GATextField = {
        let view = GATextField()
        view.configure(name: "暱稱: ")
        view.isUserInteractionEnabled = false
        view.bottomLine.isHidden = true
        return view
    }()
    
    private let contactLabel:UILabel = {
        let view = UILabel()
        view.text = "選擇留下的聯絡方法："
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 24, weight: .bold)
        view.numberOfLines = 0
        return view
    }()
    
    private let dateLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .secondaryLabel
        return view
    }()
    private let locationLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .secondaryLabel
        return view
    }()
    private let confirmButton:GradientButton = {
        let view = GradientButton(type: .system)
        view.setTitleColor(.white, for: .normal)
        view.setGradient(colors: [.lightMainColor,.darkMainColor], startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 0.9))
        view.setTitle("確認", for: .normal)
        return view
    }()
    
    
    private let eventID:String
    private let event:Event
    private var contacts:Contacts
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    private let bottomOffset:CGFloat = 150
    var completion: (() -> Void)?
    
    // MARK: - Init
    
    init(vm:EnrollViewModel){
        nameField.text = vm.currentUser.name ?? vm.currentUser.username
        titleLabel.text = vm.eventTitle
        dateLabel.text = vm.dateString
        locationLabel.text = vm.location
        eventID = vm.eventID
        event = vm.event
        contacts = vm.contacts
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackBackground
        scrollView.keyboardDismissMode = .interactive
        setupScrollView()
        anchorSubviews()
        setupContactsButton()
        observeKeyboardChange()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func didTapView(){
        view.endEditing(true)
    }
    
    private let igButton = ContactButton()
    private let tgButton = ContactButton()
    private let phoneButton = ContactButton()
    private let emptyButton : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.darkMainColor.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        let label = UILabel()
        label.text = "不留聯絡方法"
        view.addSubview(label)
        label.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 10, left: 20, bottom: 10, right: 20))
        return view
    }()
    
    
    @objc func contactViewTapped(_ sender: UITapGestureRecognizer) {
        // Unhighlight all views
        
        view.endEditing(true)
        
        [igButton,tgButton,phoneButton].forEach({$0.isSelected = false})
        emptyButton.layer.borderColor = UIColor.opaqueSeparator.cgColor
        
        if let senderView = sender.view as? ContactButton {
            senderView.isSelected = true
        }else {
            sender.view?.layer.borderColor = UIColor.darkMainColor.cgColor
        }
    }

    
    // MARK: - Keyboard Handling
    private func observeKeyboardChange(){
        
        observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {[weak self] notification in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + self!.bottomOffset, right: 0)
                }
            
        }
        
        hideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self!.bottomOffset, right: 0)
        }
    }
    
    
    fileprivate func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        scrollView.alwaysBounceVertical = true
        
        let guide = view.safeAreaLayoutGuide
        scrollView.anchor(
            top: guide.topAnchor,
            leading: guide.leadingAnchor,
            bottom: guide.bottomAnchor,
            trailing: guide.trailingAnchor)
        
        containerView.anchor(
            top: scrollView.topAnchor,
            leading: scrollView.leadingAnchor,
            bottom: scrollView.bottomAnchor,
            trailing: scrollView.trailingAnchor)
        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        
        scrollView.contentInset = .init(top: 0, left: 0, bottom: bottomOffset, right: 0)
    }
    
    fileprivate func anchorSubviews() {
        [titleLabel,
         nameField,
         locationLabel,
         titleLabel,
         dateLabel,
        ].forEach({containerView.addSubview($0)})
        
        view.addSubview(confirmButton)
        
        titleLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor,padding: .init(top: 50, left: 0, bottom: 0, right: 0))
        
        dateLabel.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        locationLabel.anchor(top: dateLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        nameField.anchor(top: locationLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 50, left: 20, bottom: 30, right: 20))
        nameField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        confirmButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 30, bottom: 60, right: 30),size: .init(width: 0, height: 50))
        confirmButton.layer.cornerRadius = 15
        
        
        nameField.delegate = self
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        //        genderButton.addTarget(self, action: #selector(didTapGenderButton), for: .touchUpInside)
        
    }
    
    private func setupContactsButton(){
        
        igButton.configure(title: "Instagram:", text: contacts.instagram)
        tgButton.configure(title: "Telegram:", text: contacts.telegram)
        phoneButton.configure(title: "電話", text: contacts.phone)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(contactViewTapped(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(contactViewTapped(_:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(contactViewTapped(_:)))
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(contactViewTapped(_:)))
        
        igButton.addGestureRecognizer(tapGesture1)
        tgButton.addGestureRecognizer(tapGesture2)
        phoneButton.addGestureRecognizer(tapGesture3)
        emptyButton.addGestureRecognizer(tapGesture4)
        
        [contactLabel,igButton,tgButton,phoneButton,emptyButton].forEach({
            containerView.addSubview($0)
            
        })
        contactLabel.anchor(top: nameField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 10, left: 30, bottom: 0, right: 30))
        
        let padding:CGFloat = 30
        emptyButton.anchor(top: contactLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 10, left: 30, bottom: 0, right: 30))
        igButton.anchor(top: emptyButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 10, left: padding, bottom: 0, right: padding))
        tgButton.anchor(top: igButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 10, left: padding, bottom: 0, right: padding))
        phoneButton.anchor(top: tgButton.bottomAnchor, leading: view.leadingAnchor, bottom: containerView.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 10, left: padding, bottom: 0, right: padding))
        
    }
    // MARK: - Register Event
    
    @objc func didTapConfirm(){
        
        LoadingIndicator.shared.showLoadingIndicator(on: view)
        
        FunctionsManager.shared.registerEvent(event: event) { [weak self] success,message  in
            LoadingIndicator.shared.hideLoadingIndicator()
            
            if success {
                self?.completion?()
                self?.dismiss(animated: true)
            } else {
                AlertManager.shared.showAlert(title: "Oops~", message: message, from: self!)
            }
        }
    }
    
    
    
    
}


extension EnrollViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text,
              !text.isEmpty else {return}
        UserDefaults.standard.set(text, forKey: "name")
        textField.resignFirstResponder()
        
    }
}



