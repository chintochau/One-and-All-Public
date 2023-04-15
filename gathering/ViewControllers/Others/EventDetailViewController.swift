//
//  EventDetailViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-27.
//

import UIKit
import IGListKit
import SwipeCellKit
import SDWebImage


class EventDetailViewController: UIViewController {
    
    var headerHeight:CGFloat = 0
    
    
    var navBarAppearance = UINavigationBarAppearance()
    
    private let collectionView :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(EventDetailInfoCell.self, forCellWithReuseIdentifier: EventDetailInfoCell.identifier)
        view.register(EventDetailParticipantsCell.self, forCellWithReuseIdentifier: EventDetailParticipantsCell.identifier)
        view.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
        view.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        view.register(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.identifier)
        view.register(EventOwnerCollectionViewCell.self, forCellWithReuseIdentifier: EventOwnerCollectionViewCell.identifier)
        view.register(TextLabelCollectionViewCell.self, forCellWithReuseIdentifier: TextLabelCollectionViewCell.identifier)
        view.register(ImageSlideShowCollectionViewCell.self, forCellWithReuseIdentifier: ImageSlideShowCollectionViewCell.identifier)
        
        
        view.register(EventHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventHeaderView.identifier)
        view.register(SectionHeaderRsuableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderRsuableView.identifier)
        view.keyboardDismissMode = .interactive
        return view
        
    }()
    
    
    private lazy var refreshControl:UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return view
    }()
    
    private let buttonStackView:UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    
    // MARK: - Configure VM

    var viewModel:EventCellViewModel? {
        didSet {
            buttonStackView.arrangedSubviews.forEach({
                buttonStackView.removeArrangedSubview($0)
            })
            
            guard let vm = viewModel else {
                return
            }
            
            guard let owner = vm.organiser else {return}
            
            if AuthManager.shared.isSignedIn {
                if vm.isOrganiser {
                    configureButtonForOrganiser()
                } else if vm.isJoined {
                    configureButtonForParticipant()
                } else {
                    configureButton()
                }
            }else {
                configureLoginButton()
            }
            
            if let urlStrings = viewModel?.event.imageUrlString, !urlStrings.isEmpty {
                hasImages = true
            }else {
                hasImages = false
            }
            
            VMs = [
                OwnerViewModel(user: owner),
                EventDetailsViewModel(event: vm.event),
                EventParticipantsViewModel(event: vm.event)
            ]
            
            participantsList = []
            vm.friends.forEach({
                participantsList.append($0)
                joinedFriends.append($0.username ?? "")
            })
            
//            participantsList.append(contentsOf: vm.friends)
            participantsList.append(contentsOf: vm.participantsExcludFriends)
            
            comments = vm.comments
            latestComments = Array(comments.sorted(by: {$0.timestamp > $1.timestamp}).prefix(3))
            
            collectionView.reloadData()
        }
    }
    
    private var hasImages:Bool = false {
        didSet {
            if hasImages {
                scrollInset = view.width
            }else {
                scrollInset = 80
            }
        }
    }
    
    var participantsList:[Participant] = []
    var VMs:[ListDiffable] = []
    
    var comments:[Comment] = []
    var latestComments:[Comment] = []
    var commentText:String? = ""
    private var joinedFriends:[String] = []
    
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    private let bottomOffset:CGFloat = 150
    private var scrollInset:CGFloat = 0
    private let contentInsetTop:CGFloat = 44
    
    deinit {
        print("EventViewController: released")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPanBackGestureAndBackButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(didTapShare))
        
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(buttonStackView)
        
        observeKeyboardChange()
        
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.scrollIndicatorInsets = .init(top: -100, left: 0, bottom: 0, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInset = .init(top: contentInsetTop, left: 0, bottom: bottomOffset, right: 0)
        
        // Add the refresh control as a subview of the collection view layout
        collectionView.addSubview(refreshControl)
        collectionView.fillSuperview()
        buttonStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 5, left: 30, bottom: 40, right: 30),size: .init(width: view.width-60, height: 50))

        configureCollectionViewLayout()
        
        setupGradientLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    
    fileprivate func setupGradientLayer(){
        let topGradientLayer = CAGradientLayer()
        topGradientLayer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        topGradientLayer.locations = [0.3,1]
        view.layer.addSublayer(topGradientLayer)
        topGradientLayer.frame = CGRect(x: 0, y: 0, width: view.width, height: 88)
        
        
        
        let bottomGradientLayer = CAGradientLayer()
        bottomGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        bottomGradientLayer.locations = [0.3,1]
        view.layer.addSublayer(bottomGradientLayer)
        bottomGradientLayer.frame = CGRect(x: 0, y: view.height-60, width: view.width, height: 60)
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        if offset-scrollInset+88 > 0 {
            //show bar
            navigationItem.title = viewModel?.title
            navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            
        } else {
            // The header is still visible, so keep the navigation bar transparent
            navBarAppearance.configureWithTransparentBackground()
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        }
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    
    
    // MARK: - Public Functions
    
    public func configureWithID(eventID:String, eventReferencePath:String) {
        DatabaseManager.shared.fetchSingleEvent(eventID: eventID, eventReferencePath: eventReferencePath) {[weak self] event in
            guard let event = event else {
                self?.eventDoesNotExist()
                return}
            self?.viewModel = .init(event: event)
        }
    }
    
    public func configureCloseButton(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    
    // MARK: - Private Functions
    

    
    fileprivate func configureCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: view.width, height: 200)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
    }

    private func eventDoesNotExist (){
        AlertManager.shared.showAlert(title: "Oops~", message: "活動不存取或取消", buttonText: "返回", cancelText: nil, from: self) {[weak self] in
            self?.dismiss(animated: true)
        }

    }
    
    @objc private func didTapShare(){
        guard let shareString = viewModel?.event.toString(includeTime: true) else {return}
        
        // MARK: - Disable share photos for now
        
//        if let urlString = viewModel?.event.imageUrlString.first,
//           let url = URL(string: urlString){
//            SDWebImageDownloader.shared.downloadImage(with: url, options: [], progress: nil) { [weak self ] (image, data, error, finished) in
//                if let error = error {
//                    print("Error downloading image: \(error.localizedDescription)")
//                } else if let image = image {
//                    let activityViewController = UIActivityViewController(activityItems: [shareString, image], applicationActivities: nil)
//
//                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
//                    self?.present(activityViewController, animated: true, completion: nil)
//                }
//            }
//        } else {
            let activityVC = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
//        }
    }
    
    
    
    
    @objc private func didTapEnrollButton(){
        if viewModel?.isOrganiser ?? false {
            editEvent()
        }else {
            if viewModel?.isJoined ?? false {
                // if already joined, tap to unregister
                unregisterEvent()
            }else {
                // if not joined, tap to join
                if viewModel?.canJoin ?? false {
                    registerEvent()
                }else {
                    print("Full, join wait list")
                }
            }
        }
    }
    
    @objc private func didTapFormEvent(){
        
        guard let eventStatus = viewModel?.event.eventStatus,
              eventStatus != .confirmed
        else {return}
        
        // confirm this event
        // send notification to all joiners
        guard let eventID = viewModel?.event.id,
              let eventRef = viewModel?.event.referencePath,
              let eventName = viewModel?.event.title
        else {return}
        
        DatabaseManager.shared.confirmFormEvent(eventName: eventName,eventID: eventID, eventReferencePath: eventRef) { [weak self] success in
            self?.refreshPage()
        }
    }
    
    @objc private func didTapChat(){
        guard AuthManager.shared.isSignedIn else {
            AlertManager.shared.showAlert(title: "Oops~", message: "Please login to send message", from: self)
            return
        }
        
        guard let targetusername = viewModel?.organiser?.username else {return}
        let vc = ChatMessageViewController(targetUsername: targetusername)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapInviteFriend(){
        
        guard let event = viewModel?.event else {return}
        let vc = InviteViewController()
        vc.event = event.toUserEvent()
        
        vc.joinedFriends = joinedFriends
        
        vc.completion = { numberOfFriends in
            AlertManager.shared.showAlert(title: "", message: "已邀請\(numberOfFriends)個朋友", from: self)
        }
        presentModallyWithHero(vc)
        
        
    }
    
    
    private func editEvent(){
        // MARK: - Edit Event (need modify)
        // edit event does not have event ref, changing date will create another event, need to modify
        let vc = NewPostViewController()
        if let editPost = viewModel?.event.toNewPost() {
            vc.newPost = editPost
            // MARK: - Need Edit
//            vc.image = viewModel?.image
            vc.isEditMode = true
            vc.eventStatus = viewModel?.event.eventStatus ?? .grouping
        }
        
        vc.completion = {[weak self] event, image in
            if let _ = event {
                // event modified
                self?.dismiss(animated: true)
                self?.refreshPage()
                
            }else {
                // event deleted
                self?.dismiss(animated: false)
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        present(vc, animated: true)
    }
    
    private func registerEvent(){
        if !AuthManager.shared.isSignedIn {
            AlertManager.shared.showAlert(title: "Oops~", message: "登入後可參加活動", from: self)
        }
        
        guard let event = viewModel?.event,
              let vm = EnrollViewModel(with: event) else {
            print("Fail to create VM")
            return}
        
        let vc = EnrollViewController(vm: vm)
        vc.completion = {[weak self] in
            self?.refreshPage()
        }
        present(vc, animated: true)
    }
    
    private func unregisterEvent(){
        AlertManager.shared.showAlert(title: "要退出嗎?", buttonText: "退出", from: self) {[weak self] in
            // Perform the function here
            guard let event = self?.viewModel?.event else {return}
            DatabaseManager.shared.unregisterEvent(event: event) { bool in
                self?.refreshPage()
            }
        }
    }
    
    @objc private func didPullToRefresh(){
        refreshPage()
    }
    
    private func refreshPage(){
        guard let event = viewModel?.event,
              let vm = EnrollViewModel(with: event) else {
            print("Fail to create VM")
            return}
        
        DatabaseManager.shared.fetchSingleEvent(event: vm.event) { [weak self] event in
            guard let event = event else {
                
                self?.dismiss(animated: true)
                return
            }
            let viewModel = EventCellViewModel(event: event)
            
            if let imageUrl = viewModel.imageUrlString,
               let self = self {
                
            }else {
                viewModel.image = self?.viewModel?.image
            }
            
            self?.viewModel = viewModel
            self?.collectionView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Open user profile
    private func didTapUserProfile(participant:Participant){
        guard let user = User(with: participant) else {return}
        let vc = UserProfileViewController(user: user)
        vc.setUpPanBackGestureAndBackButton()
        presentModallyWithHero(vc)
    }
    
    
    @objc private func didTapClose(){
        dismiss(animated: true)
    }
    
}


extension EventDetailViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return VMs.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if let _ = viewModel {
                return 3
            }
            return 0
        case ..<VMs.count:
            return 1
        case VMs.count: //Comments number
            return latestComments.count+1
        case VMs.count+1: // Participants number
            return min(participantsList.count, 5)
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
            
        case 0: // Title and Owner cell
            switch indexPath.row {
            case 1 :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextLabelCollectionViewCell.identifier, for: indexPath) as! TextLabelCollectionViewCell
                cell.title = viewModel?.title
                cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventOwnerCollectionViewCell.identifier, for: indexPath) as! EventOwnerCollectionViewCell
                cell.configure(with: viewModel?.organiser)
                cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
                return cell
                
            case 0 :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSlideShowCollectionViewCell.identifier, for: indexPath) as! ImageSlideShowCollectionViewCell
                cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
                cell.heightAnchor.constraint(equalToConstant: hasImages ? view.width : 60).isActive = true
                cell.urlStrings = viewModel?.event.imageUrlString ?? []
                cell.delegate = self
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSlideShowCollectionViewCell.identifier, for: indexPath) as! ImageSlideShowCollectionViewCell
                cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
                cell.heightAnchor.constraint(equalToConstant: view.width).isActive = true
                cell.urlStrings = viewModel?.event.imageUrlString ?? []
                cell.delegate = self
                return cell
            }
            
            
        case 1: // event detail
            let vm = VMs[indexPath.section]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventDetailInfoCell.identifier, for: indexPath) as! EventDetailInfoCell
            cell.bindViewModel(vm)
            cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
            return cell
            
        case 2: // event participants number
            let vm = VMs[indexPath.section]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventDetailParticipantsCell.identifier, for: indexPath) as! EventDetailParticipantsCell
            cell.bindViewModel(vm)
            cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
            return cell
            
        case 3: // event comments
            switch indexPath.row {
            case latestComments.count: // the last cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.identifier, for: indexPath) as! TextViewCollectionViewCell
                cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
                cell.configure(withTitle: "", text: commentText)
                cell.textView.delegate = self
                cell.sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
                cell.bindViewModel(latestComments[indexPath.row])
                cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
                return cell
            }
            
            
        default: // Participants List
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.identifier, for: indexPath) as! UserCollectionViewCell
            cell.bindViewModel(participantsList[indexPath.row])
            cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section ==  VMs.count+1{
            didTapUserProfile(participant: participantsList[indexPath.row])
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch section {
        case 0:
            return .zero
        case VMs.count:
            return .init(width: view.width, height: 30)
        case VMs.count+1:
            return .init(width: view.width, height: 30)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderRsuableView.identifier, for: indexPath) as! SectionHeaderRsuableView
        sectionHeader.delegate = self
        
        switch indexPath.section {
        case VMs.count:
            sectionHeader.configure(with: .init(title: "留言:  ", buttonText: "全部(\(comments.count))", index: 2))
            return sectionHeader
        case VMs.count+1:
            if !VMs.isEmpty, let vm = VMs[2] as? EventParticipantsViewModel {
                sectionHeader.configure(with: .init(title: vm.numberOfFriends, buttonText: "全部(\(participantsList.count))", index: 3))
            }
            return sectionHeader
        default:
            return sectionHeader
        }
    }
    
    
}

extension EventDetailViewController:UITextViewDelegate,SectionHeaderReusableViewDelegate {
    // MARK: - Header Action
    func SectionHeaderReusableViewDidTapActionButton(_ view: SectionHeaderRsuableView, button: UIButton) {
        
        let vc = CollectionListViewController()
        
        switch(button.tag) {
        case 2: // comment
            vc.navigationItem.title = "留言"
            vc.items = comments.sorted(by: {$0.timestamp > $1.timestamp})
        case 3: // participants list
            vc.navigationItem.title = "參加者"
            vc.items = participantsList
        default:
            break
        }
        vc.setUpPanBackGestureAndBackButton()
        presentModallyWithHero(vc)
    }
    
    
    @objc private func didTapSend(){
        guard let vm = viewModel, let text = commentText else {return}
        DatabaseManager.shared.postComments(event: vm.event, message: text) { [weak self] success in
            if success {
                
                DatabaseManager.shared.fetchSingleEvent(event: vm.event) { [weak self] event in
                    guard let event = event else {
                        self?.dismiss(animated: true)
                        return
                    }
                    let viewModel = EventCellViewModel(event: event)
                    
                    self?.commentText = ""
                    self?.viewModel = viewModel
                    self?.collectionView.reloadData()
                    
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        commentText = textView.text
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // MARK: - Keyboard Handling
    private func observeKeyboardChange(){
        
        observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {[weak self] notification in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self?.collectionView.contentInset = UIEdgeInsets(top: self?.contentInsetTop ?? 44, left: 0, bottom: keyboardSize.height + self!.bottomOffset, right: 0)
                }
            
        }
        
        hideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.collectionView.contentInset = UIEdgeInsets(top: self?.contentInsetTop ?? 44, left: 0, bottom: self!.bottomOffset, right: 0)
        }
    }
}


extension EventDetailViewController {
    // MARK: - Bottom Buttons
    
    
    fileprivate func configureButtonForOrganiser() {
        addEditButton()
        addFormGroupButton()
        addInviteButton()
    }
    
    fileprivate func configureButtonForParticipant(){
        addQuitButton()
        addInviteButton()
    }
    
    fileprivate func configureButton(){
        if let canJoin = viewModel?.canJoin, canJoin {
            addJoinButton()
            addInviteButton()
        } else {
            addFullButton()
            addWaitListButton()
        }
    }
    
    fileprivate func configureLoginButton() {
        lazy var editButton:GradientButton = {
            let view = GradientButton(type: .system)
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .robotoMedium(ofSize: 16)
            view.setGradient(colors: [.lightMainColor,.darkMainColor], startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 0.9))
            view.setTitle("登入以參加活動", for: .normal)
            view.gradientLayer?.cornerRadius = 15
            view.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
            return view
        }()
        buttonStackView.addArrangedSubview(editButton)
        
    }
    
    @objc private func didTapLoginButton(){
        print("Show Login Page")
    }
    
    private func addEditButton(){
        
        lazy var editButton:GradientButton = {
            let view = GradientButton(type: .system)
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .robotoMedium(ofSize: 16)
            view.setGradient(colors: [.lightMainColor,.darkMainColor], startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 0.9))
            view.setTitle("編輯活動", for: .normal)
            view.gradientLayer?.cornerRadius = 15
            view.addTarget(self, action: #selector(didTapEnrollButton), for: .touchUpInside)
            return view
        }()
        buttonStackView.addArrangedSubview(editButton)
        
    }
    
    private func addQuitButton(){
        lazy var quitButton:GradientButton = {
            let view = GradientButton(type: .system)
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .robotoMedium(ofSize: 16)
            view.setGradient(colors: [.lightMainColor,.darkMainColor], startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 0.9))
            view.setTitle("退出", for: .normal)
            view.gradientLayer?.cornerRadius = 15
            view.addTarget(self, action: #selector(didTapEnrollButton), for: .touchUpInside)
            return view
        }()
        buttonStackView.addArrangedSubview(quitButton)
        
        
    }
    private func addInviteButton(){
        lazy var formGroupButton:GradientButton = {
            let view = GradientButton(type: .system)
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .robotoMedium(ofSize: 16)
            view.setGradient(colors: [.lightMainColor,.darkMainColor], startPoint: CGPoint(x: 0.5, y: 0.1), endPoint: CGPoint(x: 0.5, y: 0.9))
            view.setTitle("邀請朋友", for: .normal)
            view.gradientLayer?.cornerRadius = 15
            view.addTarget(self, action: #selector(didTapInviteFriend), for: .touchUpInside)
            return view
        }()
        buttonStackView.addArrangedSubview(formGroupButton)
    }
    
    private func addFormGroupButton(){
        let isFormed = (viewModel?.event.eventStatus ?? .grouping) == .confirmed
        lazy var formGroupButton:GradientButton = {
            let view = GradientButton(type: .system)
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .robotoMedium(ofSize: 16)
            view.setGradient(colors: [.lightMainColor,.darkMainColor], startPoint: CGPoint(x: 0.5, y: 0.1), endPoint: CGPoint(x: 0.5, y: 0.9))
            view.setTitle(isFormed ? "己成團" : "成團", for: .normal)
            view.gradientLayer?.cornerRadius = 15
            view.addTarget(self, action: #selector(didTapFormEvent), for: .touchUpInside)
            return view
        }()
        buttonStackView.addArrangedSubview(formGroupButton)
    }
    
    private func addWaitListButton(){
        if viewModel?.allowWaitList ?? false {
            lazy var quitButton:GradientButton = {
                let view = GradientButton(type: .system)
                view.setTitleColor(.white, for: .normal)
                view.titleLabel?.font = .robotoMedium(ofSize: 16)
                view.setGradient(colors:[.lightMainColor,.darkMainColor] , startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 0.9))
                view.setTitle("加入候補名單", for: .normal)
                view.gradientLayer?.cornerRadius = 15
                view.addTarget(self, action: #selector(didTapEnrollButton), for: .touchUpInside)
                return view
            }()
            buttonStackView.addArrangedSubview(quitButton)
        }
    }
    
    private func addJoinButton(){
        lazy var quitButton:GradientButton = {
            let view = GradientButton(type: .system)
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .robotoMedium(ofSize: 16)
            view.setGradient(colors: [.lightMainColor,.darkMainColor] , startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 0.9))
            view.setTitle("參加", for: .normal)
            view.gradientLayer?.cornerRadius = 15
            view.addTarget(self, action: #selector(didTapEnrollButton), for: .touchUpInside)
            return view
        }()
        buttonStackView.addArrangedSubview(quitButton)
    }
    
    private func addFullButton(){
        lazy var quitButton:GradientButton = {
            let view = GradientButton(type: .system)
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .robotoMedium(ofSize: 16)
            view.setGradient(colors:[.lightGray,.lightGray] , startPoint: .init(x: 0.5, y: 0.1), endPoint: .init(x: 0.5, y: 0.9))
            view.setTitle("已滿", for: .normal)
            view.gradientLayer?.cornerRadius = 15
            view.addTarget(self, action: #selector(didTapEnrollButton), for: .touchUpInside)
            return view
        }()
        buttonStackView.addArrangedSubview(quitButton)
    }
    
}

extension EventDetailViewController:ImageSlideShowCollectionViewCellDelegate {
    func ImageSlideShowCollectionViewCellDidTapImage(_ cell: ImageSlideShowCollectionViewCell) {
        cell.slideshow.presentFullScreenController(from: self)
    }
    
    
}
