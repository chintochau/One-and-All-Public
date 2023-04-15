//
//  FormEventViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-30.
//

import UIKit
import EmojiPicker


class CreateNewEventViewController: UIViewController {
    
    
    private let tableView:UITableView = {
        let view =  UITableView(frame: .zero, style: .grouped)
        return view
    }()
    
    private var viewModels = [[InputFieldType]()]
    private var emojiButton:UIButton?
    
    // MARK: - Class members
    
    var newEvent = NewPost()
    var selectedImage:UIImage?
    
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    var completion: ((_ event:Event, _ image:UIImage?) -> Void)?
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModels()
        view.backgroundColor = .systemBackground
        initialUser()
        configureTableView()
        setupNavBar()
        observeKeyboardChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - ViewModels
    
    private func initialUser(){
        guard let user = DefaultsManager.shared.getCurrentUser() else {return}
        newEvent.participants = [
            user.username: Participant(with: user,status: Participant.participantStatus.host)
        ]
    }
    private func configureViewModels(){
        guard let _ = DefaultsManager.shared.getCurrentUser() else {return}
        
        var location = newEvent.location.name
        if let address = newEvent.location.address {
            location = location + "\n" + address
        }
        
        viewModels = [
            [
                .imagePicker,
                .titleField(),
                .textView(title: "活動詳情: ", text: newEvent.intro,tag: 0)
            ],[
                .datePicker,
                .value(title: "地點: ", value: location),
//                .textView(title: "Additional details: ", text: "Not yeat imple.",tag: 1)
            ],[
                .headCount,
                .participants
            ]
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Nav Bar
    private func setupNavBar(){
        navigationItem.title = "刊登活動"
        navigationController?.navigationBar.tintColor = .label
        let postButton = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(didTapPost))
        let previewButton = UIBarButtonItem(image: UIImage(systemName: "doc.text.magnifyingglass"), style: .done, target: self, action:#selector(didTapPreview))
        navigationItem.rightBarButtonItems = [postButton,previewButton]
    }
    
    // MARK: - Keyboard Handling
    private func observeKeyboardChange(){
        
        observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {[weak self] notification in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+100, right: 0)
                }
            
        }
        
        hideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        }
    }
}
extension CreateNewEventViewController:UITableViewDelegate,UITableViewDataSource {
    // MARK: - TableView
    fileprivate func configureTableView() {
        view.addSubview(tableView)
        tableView.contentInset = .zero
        tableView.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.identifier)
        tableView.register(TextLabelTableViewCell.self, forCellReuseIdentifier: TextLabelTableViewCell.identifier)
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: DatePickerTableViewCell.identifier)
        tableView.register(ValueTableViewCell.self, forCellReuseIdentifier: ValueTableViewCell.identifier)
        tableView.register(HeadcountTableViewCell.self, forCellReuseIdentifier: HeadcountTableViewCell.identifier)
        tableView.register(ParticipantsTableViewCell.self, forCellReuseIdentifier: ParticipantsTableViewCell.identifier)
        tableView.register(TitleWithImageTableViewCell.self, forCellReuseIdentifier: TitleWithImageTableViewCell.identifier)
        tableView.register(PhotoGridTableViewCell.self, forCellReuseIdentifier: PhotoGridTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
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
            return cell
        case .textView(title: let title, text: let text,tag: let tag):
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.identifier, for: indexPath) as! TextViewTableViewCell
            cell.configure(withTitle: title, text: text,tag: tag)
            cell.textView.delegate = self
            return cell
        case .value(title: let title, value: let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: ValueTableViewCell.identifier, for: indexPath) as! ValueTableViewCell
            cell.configure(withTitle: title, value: value)
            return cell
        case .textLabel(text: let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: TextLabelTableViewCell.identifier, for: indexPath) as! TextLabelTableViewCell
            cell.configure(with: text)
            cell.separator(hide: true)
            return cell
        case .datePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.identifier, for: indexPath) as! DatePickerTableViewCell
            cell.delegate = self
            cell.configure(mode: .dateAndTime)
            return cell
        case .headCount:
            let cell = tableView.dequeueReusableCell(withIdentifier: HeadcountTableViewCell.identifier, for: indexPath) as! HeadcountTableViewCell
            cell.configureForNewEvent()
            cell.isOptional = true
            cell.delegate = self
            return cell
        case .participants:
            let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantsTableViewCell.identifier, for: indexPath) as! ParticipantsTableViewCell
            cell.delegate = self
            return cell
        case .titleField:
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleWithImageTableViewCell.identifier, for: indexPath) as! TitleWithImageTableViewCell
            cell.emojiButton.addTarget(self, action: #selector(openEmojiPickerModule), for: .touchUpInside)
            cell.titleField.delegate = self
            emojiButton = cell.emojiButton
            return cell
        case .imagePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotoGridTableViewCell.identifier, for: indexPath) as! PhotoGridTableViewCell
            
            cell.delegate = self
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantsTableViewCell.identifier, for: indexPath) as! ParticipantsTableViewCell
            cell.delegate = self
            return cell
        }
    }
    
    // MARK: - Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 && indexPath.section == 1 {
            let vc = LocationSearchViewController()
            vc.delegate = self
            let navVc = UINavigationController(rootViewController: vc)
            present(navVc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "活動: "
        case 1:
            return "時間/地點: "
        case 2:
            return "參加者: "
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}

extension CreateNewEventViewController {
    // MARK: - Handle Preview/ Post
    
    
    @objc private func didTapPreview(){
        view.endEditing(true)
        
        guard var event = newEvent.toEvent() else {return}
        
        event.referencePath = "events/\(event.endDate.yearWeekStringLocalTime())"
        
        let vc = PreviewViewController()
        vc.configure(with: PreviewViewModel(event: event))
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.action = didTapPost
        
        present(vc, animated: true)
        
        
    }
    
    @objc private func didTapPost(){
        view.endEditing(true)
        
        guard let event = newEvent.toEvent() else {return}
        
        if let selectedImage = selectedImage {
            publishPostWithImage { [weak self] event in
                
                self?.dismiss(animated: false)
                self?.completion?(event, selectedImage)
            }
        }else {
            DatabaseManager.shared.createEvent(with: event) { [weak self] success in
                
                
                self?.dismiss(animated: false)
                self?.completion?(event, nil)
            }
        }
    }
    
    
    private func publishPostWithImage(completion: @escaping (Event) -> Void){
        
        var imagesData = [Data?]()
        
        for img in [selectedImage] {
            guard let image = img?.sd_resizedImage(with: CGSize(width: 1024, height: 1024), scaleMode: .aspectFill),
                  let data = image.jpegData(compressionQuality: 0.5)
            else {break}
            
            imagesData.append(data)
        }
        
        
        StorageManager.shared.uploadEventImage(id: newEvent.id, data: imagesData) {[weak self] urlStrings in
            
            guard let event = self?.newEvent.toEvent(urlStrings),
                  let _ = DefaultsManager.shared.getCurrentUser()
            else {return}
            
            DatabaseManager.shared.createEvent(with: event) { done in
                completion(event)
            }
        }
    }
}

extension CreateNewEventViewController: LocationSerchViewControllerDelegate {
    // MARK: - Handle Location
    func didChooseLocation(_ VC: LocationSearchViewController, location: Location) {
        newEvent.location = location
        configureViewModels()
    }
}

extension CreateNewEventViewController:DatePickerTableViewCellDelegate {
    // MARK: - Handle DatePicker
    func DatePickerTableViewCellDelegateOnDateChanged(_ cell: DatePickerTableViewCell, startDate: Date, endDate: Date) {
        newEvent.startDate = startDate
        newEvent.endDate = endDate
    }
    
    func DatePickerDidTapAddEndTime(_ cell: DatePickerTableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}

extension CreateNewEventViewController:HeadcountTableViewCellDelegate {
    // MARK: - handle Headcount
    func HeadcountTableViewCellDidEndEditing(_ cell: HeadcountTableViewCell, headcount: Headcount) {
        newEvent.headcount = headcount
    }
    
    
    func HeadcountTableViewCellDidTapExpand(_ cell: HeadcountTableViewCell, headcount: Headcount) {
        newEvent.headcount = headcount
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}
extension CreateNewEventViewController:UITextFieldDelegate {
    // MARK: - Handle TextField
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {return}
        newEvent.title = text
    }
}

extension CreateNewEventViewController:UITextViewDelegate {
    // MARK: - Handle TextView
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            // Intro View
            newEvent.intro = textView.text
        case 1:
            // addDetail View
            print("add info not yet implemented")
        default:
            print("Invalid Tag")
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension CreateNewEventViewController:ParticipantsTableViewCellDelegate {
    // MARK: - Handle Participants
    func ParticipantsTableViewCellTextViewDidEndEditing(_ cell: ParticipantsTableViewCell, _ textView: UITextView, participants: [String : Participant]) {
        newEvent.participants = participants
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func ParticipantsTableViewCellTextViewDidChange(_ cell: ParticipantsTableViewCell, _ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    
}

extension CreateNewEventViewController:EmojiPickerDelegate {
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
        newEvent.emojiTitle = emoji
        emojiButton?.setTitle(emoji, for: .normal)
    }
    
}

extension CreateNewEventViewController:PhotoGridTableViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func PhotoGridTableViewCellSelectImage(_ view: PhotoGridTableViewCell, cell: PhotoCollectionViewCell, index:Int) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let tempImage:UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let cell = tableView.cellForRow(at: .init(row: 0, section: 0)) as? PhotoGridTableViewCell else {return}
        
        selectedImage = tempImage
        cell.images = [tempImage]
        tableView.reloadData()
        
        picker.dismiss(animated: true)
        
    }
    
}
