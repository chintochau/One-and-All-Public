//
//  EditProfileViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-25.
//

import UIKit
import FirebaseMessaging
import TagListView


class EditProfileViewController: UIViewController, TagListViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Properties
    
    let user: User
    var completion: (() -> Void)?
    
    
    
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    
    
    private var shouldUpdateImage:Bool = false
    private lazy var imagePicker = UIImagePickerController()
    private var bottomOffset:CGFloat = 100
    
    private let headerView:ProfileHeaderView = {
        
        let view = ProfileHeaderView()
        view.showEditButton()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
        
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "暱稱"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        return textField
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "姓別"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genderSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: genderType.allCases.compactMap({$0.rawValue}))
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let birthdayLabel: UILabel = {
        let label = UILabel()
        label.text = "出生日期:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let birthdayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("保存", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let interestsLabel: UILabel = {
        let label = UILabel()
        label.text = "興趣"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let interestCount:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 16)
        view.textColor = .secondaryLabel
        return view
        
    }()
    
    private let interestsSublabel:UILabel = {
        let view = UILabel()
        view.text = "添加最多3項興趣，讓別人更容易找到您。"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 14)
        view.textColor = .secondaryLabel
        return view
    }()
    
    
    
    
    private let tagListView: TagListView = {
        let tagListView = TagListView()
        tagListView.textFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        tagListView.tagBackgroundColor = .darkMainColor
        tagListView.cornerRadius = 8
        tagListView.marginX = 8
        tagListView.marginY = 8
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        tagListView.enableRemoveButton = true
        tagListView.removeButtonIconSize = 8
        return tagListView
    }()
    
    private let customInterestTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "輸入興趣"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        return textField
    }()
    
    private let addInterestButton: UIButton = {
        let button = UIButton()
        button.setTitle("添加", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let suggestedInterestsTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    
    private let contactsLabel: UILabel = {
        let label = UILabel()
        label.text = "聯絡方法"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let telegramLabel: UILabel = {
        let label = UILabel()
        label.text = "Telegram: "
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let telegramTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let instagramLabel: UILabel = {
        let label = UILabel()
        label.text = "Instagram: "
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instagramTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "電話: "
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.keyboardType = .phonePad
        return textField
    }()
    
    private let contactSubLabel:UILabel = {
        let view = UILabel()
        view.text = "只會顯示給您所允許的人，例如您參加的活動主辦方。"
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 14)
        view.textColor = .secondaryLabel
        return view
    }()
    
    private let immigrantStatusLabel:UILabel = {
        let view = UILabel()
        view.text = "移民狀況"
        view.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let immigrantStatusSegmentedControl: UISegmentedControl = {
        let items = ["加拿大出生", "PR/公民", "其他"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let immigrantYearLabel: UILabel = {
        let label = UILabel()
        label.text = "抵達日期:"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let immigrantYearPicker: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .date
        view.maximumDate = Date()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customInterestTextField.addTarget(self, action: #selector(customInterestTextFieldDidChange), for: .editingChanged)
        immigrantStatusSegmentedControl.addTarget(self, action: #selector(immigrantStatusSegmentedControlDidChange), for: .valueChanged)
        
        setupViews()
        setupConstraints()
        
        configureuserInfo()
        
        tagListView.delegate = self
        scrollView.keyboardDismissMode = .interactiveWithAccessory
        
        
        customInterestTextField.delegate = self
        addInterestButton.addTarget(self, action: #selector(addInterestButtonTapped), for: .touchUpInside)
        
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        
        
        suggestedInterestsTableView.delegate = self
        suggestedInterestsTableView.dataSource = self
        suggestedInterestsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapPickImage))
        headerView.imageView.addGestureRecognizer(gesture)
        
        observeKeyboardChange()
        
    }
    
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "編輯個人檔案"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationController?.navigationBar.tintColor = .label
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        
        
        contentView.addSubview(interestsLabel)
        contentView.addSubview(tagListView)
        contentView.addSubview(customInterestTextField)
        contentView.addSubview(addInterestButton)
        
        contentView.addSubview(interestCount)
        contentView.addSubview(interestsSublabel)
        
        contentView.addSubview(headerView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderSegmentedControl)
        contentView.addSubview(birthdayLabel)
        contentView.addSubview(birthdayDatePicker)
        contentView.addSubview(saveButton)
        
        
        
        
        
        [immigrantYearLabel,immigrantStatusLabel,immigrantYearPicker,immigrantStatusSegmentedControl,contactSubLabel,
         contactsLabel,instagramLabel,instagramTextField,telegramLabel,telegramTextField,phoneLabel,phoneTextField
        ].forEach({contentView.addSubview($0)})
        
        
        
        
        contentView.addSubview(suggestedInterestsTableView)
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        
        headerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, size: .init(width: 0, height: 200))
        headerView.configure(with: .init(user: user))
        
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            
            nameLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            genderLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            immigrantStatusLabel.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor,constant: 16),
            immigrantStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            
            immigrantStatusSegmentedControl.topAnchor.constraint(equalTo: immigrantStatusLabel.bottomAnchor,constant: 8),
            immigrantStatusSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            immigrantStatusSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            
            
            immigrantYearLabel.topAnchor.constraint(equalTo: immigrantStatusSegmentedControl.bottomAnchor, constant: 8),
            immigrantYearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            
            immigrantYearPicker.topAnchor.constraint(equalTo: immigrantYearLabel.topAnchor,constant: 0),
            immigrantYearPicker.leadingAnchor.constraint(equalTo: immigrantYearLabel.trailingAnchor,constant: 8),
            immigrantYearPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20),
            
            birthdayLabel.topAnchor.constraint(equalTo: immigrantYearPicker.bottomAnchor, constant: 16),
            birthdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            birthdayDatePicker.topAnchor.constraint(equalTo: birthdayLabel.topAnchor, constant: 0),
            birthdayDatePicker.leadingAnchor.constraint(equalTo: birthdayLabel.trailingAnchor, constant: 8),
            birthdayDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            
            
            interestsLabel.topAnchor.constraint(equalTo: birthdayDatePicker.bottomAnchor, constant: 16),
            interestsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            interestCount.bottomAnchor.constraint(equalTo: interestsLabel.bottomAnchor),
            interestCount.leadingAnchor.constraint(equalTo: interestsLabel.trailingAnchor,constant: 10),
            
            interestsSublabel.topAnchor.constraint(equalTo: interestsLabel.bottomAnchor,constant: 5),
            interestsSublabel.leadingAnchor.constraint(equalTo: interestsLabel.leadingAnchor),
            
            tagListView.topAnchor.constraint(equalTo: interestsSublabel.bottomAnchor, constant: 5),
            tagListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tagListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            customInterestTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            customInterestTextField.trailingAnchor.constraint(equalTo: addInterestButton.leadingAnchor, constant: -8),
            customInterestTextField.heightAnchor.constraint(equalToConstant: 40),
            customInterestTextField.topAnchor.constraint(equalTo: tagListView.bottomAnchor, constant: 5),
            
            addInterestButton.topAnchor.constraint(equalTo: customInterestTextField.topAnchor),
            addInterestButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addInterestButton.widthAnchor.constraint(equalToConstant: 60),
            addInterestButton.heightAnchor.constraint(equalToConstant: 40),
            
            suggestedInterestsTableView.topAnchor.constraint(equalTo: customInterestTextField.bottomAnchor),
            suggestedInterestsTableView.leadingAnchor.constraint(equalTo: customInterestTextField.leadingAnchor),
            suggestedInterestsTableView.trailingAnchor.constraint(equalTo: addInterestButton.trailingAnchor),
            suggestedInterestsTableView.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: telegramTextField.bottomAnchor, constant: 32),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        
        contactsLabel.anchor(top: customInterestTextField.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        contactSubLabel.anchor(top: contactsLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 20, right: 20))
        
        
        phoneLabel.anchor(top: contactSubLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 0, right: 20))
        phoneTextField.anchor(top: phoneLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 0, right: 20))
        
        instagramLabel.anchor(top: phoneTextField.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 0, right: 20))
        instagramTextField.anchor(top: instagramLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 0, right: 20))
        
        
        telegramLabel.anchor(top: instagramTextField.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 0, right: 20))
        telegramTextField.anchor(top: telegramLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 0, right: 20))
        
    }
    
    
    
    
    
    private func genderSegmentedControlIndex(from gender: String) -> Int {
        switch gender {
        case genderType.male.rawValue:
            return 0
        case genderType.female.rawValue:
            return 1
        default:
            return 2
        }
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTag(title)
        
        interestCount.text = "\(tagListView.tagViews.count)/3"
    }
    
    
    
    
    var suggestedInterests = [String]()
    
    @objc private func addInterestButtonTapped() {
        guard let interest = customInterestTextField.text, !interest.isEmpty else {
            return
        }
        
        if isMaxInterestsReached() {
            return
        }
        
        
        tagListView.addTag(interest)
        customInterestTextField.text = nil
        interestCount.text = "\(tagListView.tagViews.count)/3"
    }
    
    private func isMaxInterestsReached() -> Bool {
        if tagListView.tagViews.count < 3 {
            return false
        } else {
            AlertManager.shared.showAlert(title: "", message: "最多可輸入三項興趣。", from: self)
            return true
        }
    }
    
    
    @objc private func customInterestTextFieldDidChange() {
        guard let text = customInterestTextField.text, !text.isEmpty else {
            suggestedInterestsTableView.isHidden = true
            return
        }
        
        let interests = Event.interests
        let matchingInterests = interests.filter { $0.lowercased().contains(text.lowercased()) }
        suggestedInterests = matchingInterests
        suggestedInterestsTableView.isHidden = matchingInterests.isEmpty
        
        suggestedInterestsTableView.reloadData()
    }
    
    @objc private func immigrantStatusSegmentedControlDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            immigrantYearPicker.isHidden = true
            immigrantYearLabel.isHidden = true
        default:
            immigrantYearPicker.isHidden = false
            immigrantYearLabel.isHidden = false
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedInterests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggestedInterests[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isMaxInterestsReached() {
            return
        }
        
        
        let selectedInterest = suggestedInterests[indexPath.row]
        tagListView.addTag(selectedInterest)
        customInterestTextField.text = nil
        suggestedInterestsTableView.isHidden = true
        interestCount.text = "\(tagListView.tagViews.count)/3"
    }
    
    
    // MARK: - Load user Info
    private func configureuserInfo(){
        
        nameTextField.text = user.name
        genderSegmentedControl.selectedSegmentIndex = genderSegmentedControlIndex(from:user.gender ?? "male")
        
        interestCount.text = "\(user.interests?.count ?? 0)/3"
        
        if let birthday = user.birthday {
            birthdayDatePicker.date = birthday
        }
        tagListView.addTags(user.interests ?? [])
        
        if let immigrantStatus = user.immigrantStatus {
            
            switch immigrantStatus {
            case .bornInCanada:
                immigrantStatusSegmentedControl.selectedSegmentIndex = 0
                
                immigrantYearPicker.isHidden = true
                immigrantYearLabel.isHidden = true
            case .PR(year: let year):
                immigrantStatusSegmentedControl.selectedSegmentIndex = 1
                
                immigrantYearPicker.date = year
            case .other(year: let year):
                immigrantStatusSegmentedControl.selectedSegmentIndex = 2
                print(year)
                immigrantYearPicker.date = year
            }
        } else {
            
            immigrantStatusSegmentedControl.selectedSegmentIndex = 2
        }
        
        if let contacts = user.contacts {
            instagramTextField.text = contacts.instagram
            telegramTextField.text = contacts.telegram
            phoneTextField.text = contacts.phone
        }
    }
    
    // MARK: - Save Profile
    
    
    @objc private func saveButtonTapped() {
        
        guard let name = nameTextField.text,
              name.count >= 2 else {
            AlertManager.shared.showAlert(title: "", message: "暱稱應至少包含兩個字，請重新輸入。", from:self)
            return
        }
        
        view.endEditing(true)
        
        LoadingIndicator.shared.showLoadingIndicator(on: view)
        
        if shouldUpdateImage {
            StorageManager.shared.uploadprofileImage(image: (headerView.imageView.image)!) {[weak self] urlString in
                self?.updateDatabase(urlString)
            }
        }else {
            updateDatabase()
        }
        
        
        
    }
    
    
    fileprivate func updateDatabase(_ urlString: String? = nil) {
        guard let _ = UserDefaults.standard.string(forKey: "username"),
              let _ = UserDefaults.standard.string(forKey: "email"),
              let name = nameTextField.text else {return}
        
        let gender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)
        let birthday = birthdayDatePicker.date
        let interests = tagListView.tagViews.compactMap({$0.currentTitle})
        
        
        
        let contacts = Contacts(instagram: instagramTextField.text, telegram: telegramTextField.text, phone: phoneTextField.text)
        
        var immigrantStatus = ImmigrantStatus.bornInCanada
        
        switch immigrantStatusSegmentedControl.selectedSegmentIndex {
        case 0:
            immigrantStatus = .bornInCanada
        case 1:
            immigrantStatus = .PR(year: immigrantYearPicker.date)
        case 2:
            immigrantStatus = .other(year: immigrantYearPicker.date)
        default:
            break
        }
        
        let updatedUser = User(username: user.username,
                               email: user.email,
                               name: name,
                               profileUrlString: urlString,
                               gender: gender,
                               birthday: birthday,
                               rating: user.rating,
                               fcmToken: Messaging.messaging().fcmToken,
                               chatToken: user.chatToken,interests: interests,contacts: contacts,
                               immigrantStatus: immigrantStatus)
        
        DatabaseManager.shared.updateUserProfile(user: updatedUser) { [weak self] user in
            
            LoadingIndicator.shared.hideLoadingIndicator()
            DefaultsManager.shared.updateUserProfile(with: user)
            
            self?.completion?()
            
            self?.dismiss(animated: true)
        }
    }
    
    
}


extension EditProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    // MARK: - Pick Image
    @objc func didTapPickImage(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        
        headerView.imageView.image = tempImage
        shouldUpdateImage = true
        
        imagePicker.dismiss(animated: true)
        
    }
    
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        suggestedInterestsTableView.isHidden = true
    }
    
}
