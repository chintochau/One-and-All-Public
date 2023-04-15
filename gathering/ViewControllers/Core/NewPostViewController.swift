//
//  NewEventViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-03.
//

import UIKit
import EmojiPicker
import DKImagePickerController


enum InputFieldType {
    case textField(title:String, placeholder:String,text:String = "")
    case textView(title:String, text:String?,tag:Int = 0)
    case value(title:String, value:String)
    case userField(username:String,name:String?, profileUrl:String?)
    case textLabel(text:String)
    case datePicker
    case headCount
    case participants
    case titleField(title:String? = nil,placeholder:String? = nil)
    case horizentalPicker(title:String,selectedObject:Any,objects:[Any])
    case imagePicker
    case toggleButton(title:String, tag:Int)
}


class NewPostViewController: UIViewController {
    
    
    // MARK: - Components
    private let tableView:UITableView = {
        let view =  UITableView(frame: .zero, style: .grouped)
        return view
    }()
    
    
    private var emojiButton:UIButton?
    
    private let headerView:UIView = {
        let view = UIView()
        return view
    }()
    
    
    private let tempButton:UIButton = {
        let view = UIButton()
        view.setTitle("提交", for: .normal)
        view.setTitleColor(.label, for: .normal)
        return view
    }()
    
    private let deleteButton:UIButton = {
        let view = UIButton()
        view.setTitle("刪除", for: .normal)
        view.setTitleColor(.red, for: .normal)
        view.isHidden = true
        return view
    }()
    
    lazy var imagePicker = UIImagePickerController()
    
    // MARK: - Class members
    private var viewModels = [[InputFieldType]()]
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    var completion: ((_ event:Event?,_ images:[UIImage]) -> Void)?
    
    
    private let bottomOffset:CGFloat = 200
    var newPost = NewPost()
    
    var images:[UIImage] = [] {
        didSet {
            if let cell = tableView.cellForRow(at: .init(row: 0, section: 0)) as? ImagesTableViewCell {
                cell.images = images
                tableView.reloadData()
            }
        }
    }
    
    private var isImageEdited:Bool = false
    
    var isEditMode:Bool = false {
        didSet {
            deleteButton.isHidden = !isEditMode
            
        }
    }
    
    var eventStatus:EventStatus? {
        didSet {
            guard let eventStatus = eventStatus else {return}
            switch eventStatus {
            case .grouping:
                break
            case .confirmed:
                deleteButton.setTitle("取消活動", for: .normal)
            case .activity:
                break
            case .cancelled:
                break
            }
        }
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModels()
        view.backgroundColor = .systemBackground
        initialUser()
        configureTableView()
        setupNavBar()
        observeKeyboardChange()
        
        
        view.addSubview(tempButton)
        
        tempButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 30, right: 60))
        tempButton.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        
        view.addSubview(deleteButton)
        deleteButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 60, bottom: 30, right: 0))
        deleteButton.addTarget(self, action: #selector(didTapDeleteEvent), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - ViewModels
    
    private func initialUser(){
        guard let user = DefaultsManager.shared.getCurrentUser() else {return}
        newPost.participants = [
            user.username: Participant(with: user,status: Participant.participantStatus.host)
        ]
    }
    
    private func configureViewModels(){
        guard let _ = DefaultsManager.shared.getCurrentUser() else {return}
        
        var locationArray:[Location] = Location.torontoLocationArray
        
        if let currentlocation = Location.getCurrentLocation() {
//            if currentlocation == .hongkong {
//                locationArray = Location.hongkongLocationArray
//
//            }
            
            
        }
        
        
        
        viewModels = [
            [
                .imagePicker,
                .titleField(title: "活動名稱" ,placeholder: "例： 滑雪/食日本野/周末聚下..."),
                .textView(title: "活動簡介:", text: newPost.intro,tag: 0),
                .datePicker,
                .horizentalPicker(title: "地點:", selectedObject: newPost.location, objects: locationArray),
                .headCount,
                .toggleButton(title: "允許候補名單", tag:2),
                .toggleButton(title: "自動確認報名", tag:1)
            ]
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Nav Bar
    private func setupNavBar(){
        navigationItem.title = "快速組團"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(didTapClose))
        let postButton = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(didTapPost))
        let previewButton = UIBarButtonItem(image: UIImage(systemName: "doc.text.magnifyingglass"), style: .done, target: self, action:#selector(didTapPreview))
        navigationItem.rightBarButtonItems = [postButton,previewButton]
    }
    
    @objc private func didTapClose(){
        
        self.dismiss(animated: true)
        
    }
    
    // MARK: - Keyboard Handling
    private func observeKeyboardChange(){
        
        observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {[weak self] notification in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + self!.bottomOffset, right: 0)
                }
            
        }
        
        hideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self!.bottomOffset, right: 0)
        }
    }
}

extension NewPostViewController:UITableViewDelegate,UITableViewDataSource {
    // MARK: - TableView
    fileprivate func configureTableView() {
        
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 65, right: 0))
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.backgroundView = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.register(ToggleButtonTableViewCell.self, forCellReuseIdentifier: ToggleButtonTableViewCell.identifier)
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.identifier)
        tableView.register(TextLabelTableViewCell.self, forCellReuseIdentifier: TextLabelTableViewCell.identifier)
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: DatePickerTableViewCell.identifier)
        tableView.register(ValueTableViewCell.self, forCellReuseIdentifier: ValueTableViewCell.identifier)
        tableView.register(HeadcountTableViewCell.self, forCellReuseIdentifier: HeadcountTableViewCell.identifier)
        tableView.register(ParticipantsTableViewCell.self, forCellReuseIdentifier: ParticipantsTableViewCell.identifier)
        tableView.register(TitleWithImageTableViewCell.self, forCellReuseIdentifier: TitleWithImageTableViewCell.identifier)
        tableView.register(HorizontalCollectionView.self, forCellReuseIdentifier: HorizontalCollectionView.identifier)
        tableView.register(LocationPickerTableViewCell.self, forCellReuseIdentifier: LocationPickerTableViewCell.identifier)
        tableView.register(ImagesTableViewCell.self, forCellReuseIdentifier: ImagesTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 0, left: 0, bottom: bottomOffset, right: 0)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = viewModels[indexPath.section][indexPath.row]
        
        switch vm {
        case .userField:
            let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
            let user = DefaultsManager.shared.getCurrentUser()!
            cell.configure(with: user)
            cell.selectionStyle = .none
            cell.separator(hide: true)
            
            return cell
        case .textField(title: let title, placeholder: let placeholder,text: let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath) as! TextFieldTableViewCell
            cell.configure(withTitle: title, placeholder: placeholder,text: text)
            cell.textField.delegate = self
            cell.backgroundColor = .clear
            return cell
        case .textView(title: let title, text: let text,tag: let tag):
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.identifier, for: indexPath) as! TextViewTableViewCell
            cell.configure(withTitle: title, text: text,tag: tag)
            cell.isOptional = true
            cell.textView.delegate = self
            cell.backgroundColor = .clear
            return cell
        case .value(title: let title, value: let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: ValueTableViewCell.identifier, for: indexPath) as! ValueTableViewCell
            cell.configure(withTitle: title, value: value)
            cell.backgroundColor = .clear
            return cell
        case .textLabel(text: let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: TextLabelTableViewCell.identifier, for: indexPath) as! TextLabelTableViewCell
            cell.configure(with: text)
            cell.separator(hide: true)
            cell.backgroundColor = .clear
            return cell
        case .datePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.identifier, for: indexPath) as! DatePickerTableViewCell
            cell.delegate = self
            cell.backgroundColor = .clear
            cell.isExpanded = self.isEditMode
            cell.newPost = self.newPost
            return cell
        case .headCount:
            let cell = tableView.dequeueReusableCell(withIdentifier: HeadcountTableViewCell.identifier, for: indexPath) as! HeadcountTableViewCell
            cell.isOptional = true
            cell.delegate = self
            cell.backgroundColor = .clear
            cell.configureHeadcount(with: newPost.headcount)
            
            return cell
        case .participants:
            let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantsTableViewCell.identifier, for: indexPath) as! ParticipantsTableViewCell
            cell.delegate = self
            cell.backgroundColor = .clear
            return cell
        case .titleField(title: let title,placeholder: let placeholder):
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleWithImageTableViewCell.identifier, for: indexPath) as! TitleWithImageTableViewCell
            cell.emojiButton.addTarget(self, action: #selector(openEmojiPickerModule), for: .touchUpInside)
            cell.titleField.delegate = self
            cell.titleField.placeholder = placeholder
            cell.titleLabel.text = title
            cell.titleField.text = newPost.title
            emojiButton = cell.emojiButton
            cell.emojiButton.setTitle(newPost.emojiTitle, for: .normal)
            cell.backgroundColor = .clear
            return cell
        case .horizentalPicker(title: let title,selectedObject: let selectedObject, objects: let objects):
            let cell = tableView.dequeueReusableCell(withIdentifier: LocationPickerTableViewCell.identifier, for: indexPath) as! LocationPickerTableViewCell
            cell.configure(title: title, selectedObject: selectedObject, with: objects)
            cell.isOptional = true
            cell.delegate  = self
            cell.backgroundColor = .clear
            if !isEditMode {
                cell.selectInitialCell()
            }
            return cell
        case .imagePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesTableViewCell.identifier, for: indexPath) as! ImagesTableViewCell
            cell.configureImageViews(with: view.width)
            cell.images = self.images
            return cell
        case .toggleButton(title: let title, tag: let tag):
            let cell = tableView.dequeueReusableCell(withIdentifier: ToggleButtonTableViewCell.identifier, for: indexPath) as! ToggleButtonTableViewCell
            cell.configure(title: title, isOn: tag == 1 ? newPost.autoApprove : newPost.allowWaitList, tag:tag)
            cell.delegate = self
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    // MARK: - Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        if indexPath.row == 0 {
//            imagePicker.sourceType = .photoLibrary
//            imagePicker.allowsEditing = true
//
//            present(imagePicker, animated: true)
            
            presentImagePicker()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            
            let titleLabel:UILabel = {
                let view = UILabel()
                view.text = "您可以設置活動標題和其他細節，吸引有相似興趣的人加入您的活動，讓您在新社會中找到志同道合的朋友。"
                view.numberOfLines = 0
                view.font = .helvetica(ofSize: 14)
                return view
            }()
            headerView.addSubview(titleLabel)
            titleLabel.anchor(top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, trailing: headerView.trailingAnchor, padding: .init(top: 10, left: 30, bottom: 10, right: 30))
            
            return headerView
        }
        return nil
    }
    
    
}



extension NewPostViewController {
    // MARK: - Handle Preview/ Post
    
    private func createPostFromNewPost() -> Event?{
        newPost.toEvent()
    }
    
    @objc private func didTapPreview(){
        view.endEditing(true)
        
        guard let event = createPostFromNewPost(), event.title.count > 1 else {
            AlertManager.shared.showAlert(title: "Oops~", message: "請輸入最少兩個字的標題", from: self)
            return
        }
        
        
        
        let vc = PreviewViewController()
        vc.configure(with: PreviewViewModel(event: event))
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.action = didTapPost
        present(vc, animated: true)
    }
    
    @objc private func didTapPost(){
        view.endEditing(true)
        
        guard let event = createPostFromNewPost(), event.title.count > 1 else {
            AlertManager.shared.showAlert(title: "Oops~", message: "請輸入最少兩個字的標題", from: self)
            return
        }
        
        
        LoadingIndicator.shared.showLoadingIndicator(on: view)
        
        if isImageEdited {
            publishPostWithImage { [weak self] finalEvent in
                LoadingIndicator.shared.hideLoadingIndicator()
                self?.navigationController?.popToRootViewController(animated: false)
                self?.dismiss(animated: false)
                self?.completion?(finalEvent, self?.images ?? [])
            }
            
        }else {
            DatabaseManager.shared.createEvent(with: event) { [weak self] finalEvent in
                LoadingIndicator.shared.hideLoadingIndicator()
                self?.navigationController?.popToRootViewController(animated: false)
                self?.dismiss(animated: false)
                self?.completion?(finalEvent,[])
            }
        }
    }
    
    @objc private func didTapDeleteEvent(){
        view.endEditing(true)
        guard let eventRef = newPost.eventRef else {return}
        
        if let eventStatus = eventStatus, eventStatus == .confirmed {
            // if event already confirm, cannot delete, only cancelled is allowed
            print("Not Yet Implemented")
            
        }else {
            DatabaseManager.shared.deleteEvent(eventID:newPost.id, eventRef: eventRef) { [weak self] _ in
                // need to modify, should return success instead of an event
                self?.dismiss(animated: false)
                self?.completion?(nil, [])
            }
        }
    }
    
    
    
    private func publishPostWithImage(completion: @escaping (Event) -> Void){
        let imagesData:[Data?] = images.compactMap { img in
            
            let aspectRatio = img.size.width / img.size.height
                   
                   // Calculate the new size based on the aspect ratio and maximum size of 1024 on the short edge
                   let newSize: CGSize
                   if aspectRatio >= 1.0 {
                       newSize = CGSize(width: 1024, height: 1024 / aspectRatio)
                   } else {
                       newSize = CGSize(width: 1024 * aspectRatio, height: 1024)
                   }
                   
            
            guard let image = img.sd_resizedImage(with: newSize, scaleMode: .aspectFill),
                  let data = image.jpegData(compressionQuality: 0.3)
            else { return nil }
            return data
            
            
            
        }
        
        StorageManager.shared.uploadEventImage(id: newPost.id, data: imagesData) {[weak self] urlStrings in
            
            guard let event = self?.newPost.toEvent(urlStrings),
                  let _ = DefaultsManager.shared.getCurrentUser()
            else {return}
            
            DatabaseManager.shared.createEvent(with: event) { finalEvent in
                completion(finalEvent)
            }
        }
    }
    
    
}


extension NewPostViewController {
    // MARK: - Pick Image
    
    func presentImagePicker() {
        
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 4
        pickerController.view.backgroundColor = .systemBackground
        pickerController.sourceType = .photo
        pickerController.showsCancelButton = true
        
        let group = DispatchGroup()
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            var images = [UIImage]()
            for asset in assets {
                group.enter()
                asset.fetchOriginalImage() { image, info in
                    if let image = image {
                        images.append(image)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                if !images.isEmpty {
                    self.isImageEdited = true
                    self.images = images
                }
            }
            
            // Do something with the selected images
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    
}

extension NewPostViewController:DatePickerTableViewCellDelegate {
    // MARK: - Handle DatePicker
    func DatePickerTableViewCellDelegateOnDateChanged(_ cell: DatePickerTableViewCell, startDate: Date, endDate: Date) {
        newPost.startDate = startDate
        newPost.endDate = endDate
    }
    
    func DatePickerDidTapAddEndTime(_ cell: DatePickerTableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}

extension NewPostViewController:HeadcountTableViewCellDelegate {
    // MARK: - handle Headcount
    func HeadcountTableViewCellDidEndEditing(_ cell: HeadcountTableViewCell, headcount: Headcount) {
        newPost.headcount = headcount
        
    }
    
    
    func HeadcountTableViewCellDidTapExpand(_ cell: HeadcountTableViewCell, headcount: Headcount) {
        tableView.beginUpdates()
        tableView.endUpdates()
        newPost.headcount = headcount
        
    }
    
}
extension NewPostViewController:UITextFieldDelegate {
    // MARK: - Handle TextField
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {return}
        newPost.title = text
    }
}

extension NewPostViewController:UITextViewDelegate {
    // MARK: - Handle TextView
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            newPost.intro = textView.text
            if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TextViewTableViewCell {
                cell.textCount.text = "\(textView.text.count)/1000"
            }
        case 1:
            // addDetail View
            print("add info not yet implemented")
        default:
            print("Invalid Tag")
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.tag == 0 {
            
            if textView.text.count >= 1000 {
                // Assume textView is a UITextView object
                let startIndex = 1000

                // Set the selected range of the text view to start at the specified index and extend to the end of the text
                let endIndex = textView.text.count
                let range = NSRange(location: startIndex, length: endIndex - startIndex)
                textView.selectedRange = range

                // Delete the selected text
                textView.deleteBackward()
            }
            
            return textView.text.count < 1000
        }
        return true
    }
}

extension NewPostViewController:ParticipantsTableViewCellDelegate {
    // MARK: - Handle Participants
    func ParticipantsTableViewCellTextViewDidEndEditing(_ cell: ParticipantsTableViewCell, _ textView: UITextView, participants: [String : Participant]) {
        newPost.participants = participants
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func ParticipantsTableViewCellTextViewDidChange(_ cell: ParticipantsTableViewCell, _ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    
}

extension NewPostViewController:EmojiPickerDelegate {
    // MARK: - Pick Emoji
    
    @objc private func openEmojiPickerModule(sender: UIButton) {
        let viewController = EmojiPickerViewController()
        viewController.selectedEmojiCategoryTintColor = .mainColor
        viewController.delegate = self
        viewController.sourceView = sender
        present(viewController, animated: true)
    }
    
    
    func didGetEmoji(emoji: String) {
        UserDefaults.standard.setValue(emoji, forKey: "selectedEmoji")
        newPost.emojiTitle = emoji
        emojiButton?.setTitle(emoji, for: .normal)
    }
    
}



// MARK: - Handle Location
extension NewPostViewController:LocationPickerTableViewCellDelegate {
    func didStartEditing(_ cell: LocationPickerTableViewCell, textField: UITextField) {
        textField.resignFirstResponder()
        let vc = LocationSearchViewController()
        vc.delegate = self
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    func didChangeText(_ cell: LocationPickerTableViewCell, textField: UITextField) {
        
    }
    
    func didEndEditing(_ cell: LocationPickerTableViewCell, textField: UITextField) {
        
    }
    
    func didSelectLocation(_ cell: LocationPickerTableViewCell, didSelectObject object: Any) {
        if let object = object as? Location {
            newPost.location = object
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension NewPostViewController: LocationSerchViewControllerDelegate {
    func didChooseLocation(_ VC: LocationSearchViewController, location: Location) {
        newPost.location = location
        configureViewModels()
    }
}

extension NewPostViewController:ToggleButtonTableViewCellDelegate {
    // MARK: - Handle Toggle Button
    func ToggleButtonTableViewCellDidToggle(_ cell: ToggleButtonTableViewCell, afterValue: Bool, tag: Int) {
        switch tag {
        case 1:
            // Auto approve
            newPost.autoApprove = afterValue
        case 2:
            // Allow Waitlist
            newPost.allowWaitList = afterValue
        default:
            print("Toggle tag not defined")
        }
    }
}
