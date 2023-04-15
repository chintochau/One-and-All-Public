//
//  EventViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-18.
//

/* version 0
 
 import UIKit

  
  enum newEventPageType:String {
      case photoField = "Photo"
      case titleField = "Title"
      case desctiptionField = "Description"
      case locationField = "Location"
      case refundField = "Refund Policy"
      case dateField = "Date"
      case priceField = "Price"
      case headCount
  }


 class OldEventController: UIViewController{
     
     deinit{
         print("released")
     }
     
     private var tempEvent = NewPost()
     
     private let picker = UIImagePickerController()
     
     private static let imageCount:Int = 1
     
     private var images = [UIImage?](repeating: nil, count: imageCount)
     private var imageCells = [PhotoCollectionViewCell](repeating: PhotoCollectionViewCell(), count: imageCount)
     private var currentIndex:Int = 0
     private var observer: NSObjectProtocol?
     private var hideObserver: NSObjectProtocol?
     
     private var tableView:UITableView = {
         let view = UITableView(frame: .zero, style: .grouped)
         return view
     }()
     
     
     private let buttonView = UIView()
     private let publishButton = GAButton(type: .system)
     private let previewButton = GAButton(type: .system)
     private let activatyIndicator:UIActivityIndicatorView = {
         let view = UIActivityIndicatorView()
         view.isHidden = true
         view.hidesWhenStopped = true
         return view
     }()
     
     var completion: ((_ event:Event,_ image:UIImage?) -> Void)?
     
     // MARK: - ViewModels
     private let viewModels:[[newEventPageType]] = [
         [.photoField,
          .titleField,
          .desctiptionField
         ],
         [.locationField,
          .dateField,
          .priceField,
          .refundField
         ],
         [
             .headCount
         ]
     ]
     
     // MARK: - LifeCycle
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .systemBackground
         navigationItem.title = "New Event"
         configureTableView()
         observeKeyboardChange()
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Preview", style: .plain, target: self, action: #selector(didTapPreview))
     }
     
     // MARK: - TableView
     private func configureTableView(){
         tableView.dataSource = self
         tableView.delegate = self
         tableView.backgroundColor = .systemBackground
         tableView.keyboardDismissMode = .interactive
         tableView.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
         view.addSubview(tableView)
         tableView.frame = view.bounds
         tableView.rowHeight = UITableView.automaticDimension
         registerCell()
     }
     
     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
     }
     
     
     // MARK: - Register Cell
     private func registerCell(){
         tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
         tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.identifier)
         tableView.register(PhotoGridTableViewCell.self, forCellReuseIdentifier: PhotoGridTableViewCell.identifier)
         tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: DatePickerTableViewCell.identifier)
         tableView.register(HeadcountTableViewCell.self, forCellReuseIdentifier: HeadcountTableViewCell.identifier)
     }

     // MARK: - Keyboard Handling
     private func observeKeyboardChange(){
         
         observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {[weak self] notification in
             if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                 self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                 }
             
         }
         
         hideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
                 self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
         }
     }
     
 }

 // MARK: - Delegate / DataSource
 extension OldEventController: UITableViewDataSource,UITableViewDelegate {
     
     func numberOfSections(in tableView: UITableView) -> Int {
         return viewModels.count
     }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return viewModels[section].count
     }
     
     // MARK: - Field Cell
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         switch viewModels[indexPath.section][indexPath.row] {
         case .titleField:
             let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath) as! TextFieldTableViewCell
             cell.configure(with: "Title", type: .titleField)
             cell.textField.delegate = self
             return cell
             
         case .desctiptionField:
             
             let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.identifier, for: indexPath) as! TextViewTableViewCell
             cell.configure(with: "",type: .desctiptionField)
             cell.textView.delegate = self
             return cell
             
         case .photoField:
             
             let cell = tableView.dequeueReusableCell(withIdentifier: PhotoGridTableViewCell.identifier, for: indexPath) as! PhotoGridTableViewCell
             cell.delegate = self
             
             return cell
             
         case .locationField:
             
             
             let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath) as! TextFieldTableViewCell
             cell.configure(with: "Location",type: .locationField)
             cell.textField.delegate = self
             
             return cell
         case .refundField:
             
             
             let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.identifier, for: indexPath) as! TextViewTableViewCell
             cell.configure(with: "",type: .refundField)
             cell.textView.delegate = self
             return cell
             
         case .dateField:
             
             
             let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.identifier, for: indexPath) as! DatePickerTableViewCell
             cell.delegate = self
             cell.configure(mode: .dateAndTime)
             
             return cell
         case .priceField:
             
             
             let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath) as! TextFieldTableViewCell
             cell.configure(with: "Price",type: .priceField)
             cell.textField.delegate = self
             
             return cell
             
         case .headCount:
             let cell = tableView.dequeueReusableCell(withIdentifier: HeadcountTableViewCell.identifier, for: indexPath) as! HeadcountTableViewCell
             cell.delegate = self
             return cell
         }
     }
     
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
     }
     
     
     
     
     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
         
         // MARK: - Bottom View
         
         if section == viewModels.count-1 {
             
             [publishButton,previewButton,activatyIndicator].forEach{buttonView.addSubview($0)}
             
             previewButton.anchor(
                 top: buttonView.topAnchor,
                 leading: buttonView.leadingAnchor,
                 bottom: buttonView.bottomAnchor,
                 trailing: nil,
                 padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
             )
             
             previewButton.addTarget(self, action: #selector(didTapPreview), for: .touchUpInside)
             previewButton.setTitle("Preview", for: .normal)
             previewButton.backgroundColor = .lightGray
             previewButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
             
             publishButton.anchor(
                 top: buttonView.topAnchor,
                 leading: previewButton.trailingAnchor,
                 bottom: buttonView.bottomAnchor,
                 trailing: buttonView.trailingAnchor,
                 padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
             )
             
             publishButton.widthAnchor.constraint(equalTo: previewButton.widthAnchor, multiplier: 1).isActive = true
             publishButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
             publishButton.setTitle("publish", for: .normal)
             publishButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
             
             activatyIndicator.anchor(top: publishButton.topAnchor, leading: publishButton.leadingAnchor, bottom: publishButton.bottomAnchor, trailing: publishButton.trailingAnchor)
             
             
             return  buttonView
         }
         else {
             return nil
         }
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 1
     }
     
     
  
 }

 extension OldEventController:PhotoGridTableViewCellDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
     // MARK: - Image
     
     func PhotoGridTableViewCellSelectImage(_ view: PhotoGridTableViewCell, cell: PhotoCollectionViewCell, index:Int) {
         
         picker.delegate = self
         picker.allowsEditing = true
         
         imageCells[index] = cell
         currentIndex = index
         
         present(picker, animated: true)
     }
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         guard let tempImage:UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
         
         imageCells[currentIndex].imageView.image = tempImage
         imageCells[currentIndex].imageView.contentMode = .scaleAspectFill
         images[currentIndex] = tempImage
         
         picker.dismiss(animated: true)
         
     }
     
 }


 extension  OldEventController:  UITextViewDelegate, UITextFieldDelegate,DatePickerTableViewCellDelegate,HeadcountTableViewCellDelegate {
     
     // MARK: - Input Data
     
     /*
      case photoField = "photo"
      case titleField = "title"
      case desctiptionField = "description"
      case locationField = "location"
      case refundField = "refund"
      case dateField = "date"
      case priceField = "price"
      */
     
     func textViewDidBeginEditing(_ textView: UITextView) {
         textView.text = nil
     }
     
     func textViewDidChange(_ textView: UITextView) {
         tableView.beginUpdates()
         tableView.endUpdates()
         if let name = textView.layer.name,let text = textView.text {
             switch name {
             case newEventPageType.desctiptionField.rawValue:
                 tempEvent.description = text
             default:
                 print("please check type")
             }
         }
     }
     
     func textFieldDidEndEditing(_ textField: UITextField) {
         
         if let name = textField.layer.name,let text = textField.text, !text.isEmpty {
             switch name {
             case newEventPageType.titleField.rawValue:
                 tempEvent.title = text
             case newEventPageType.locationField.rawValue:
                 tempEvent.location = Location.toronto
             case newEventPageType.priceField.rawValue:
                 guard let price = Double(text) else {
                     fatalError("cannot change price to type double")}
             default:
                 print("please check type")
             }
         }
     }
     
     
     func DatePickerTableViewCellDelegateOnDateChanged(_ cell: DatePickerTableViewCell, startDate: Date, endDate: Date) {
         tempEvent.startDate = startDate
         tempEvent.endDate = endDate
         
     }
     
     func DatePickerDidTapAddEndTime(_ cell: DatePickerTableViewCell) {
         tableView.beginUpdates()
         tableView.endUpdates()
     }
     
     
     
     
     
     
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
         if let name = textField.layer.name, name == newEventPageType.priceField.rawValue,
            let price = textField.text{
             
             if price.contains(".") && string == "." {
                 return false
             }
             
             if let _ = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) {
                 return true
             }
             
             
             return string.isEmpty || string == "."
         }
         
         return true
         
     }
     
     
     func HeadcountTableViewCellDidEndEditing(_ cell: HeadcountTableViewCell, headcount: Headcount) {
         
         tempEvent.headcount = headcount
     }
     
     func HeadcountTableViewCellDidTapExpand(_ cell: HeadcountTableViewCell, headcount: Headcount) {
         
         tableView.beginUpdates()
         tableView.endUpdates()
     }
     
     
 }

 extension OldEventController {
     // MARK: - Preview/Submit
     
     @objc private func didTapSubmit (){
         view.endEditing(true)
         
         guard let previewEvent = configurePreviewEvent() else {return}
         
         publishButton.isHidden = true
         activatyIndicator.startAnimating()
         
         publishPost(with: previewEvent) {[weak self] event in
             self?.publishButton.isHidden = false
             self?.activatyIndicator.stopAnimating()
             self?.navigationController?.popToRootViewController(animated: false)
             self?.completion?(event, self?.images[0])
             
         }
     }
     
     @objc private func didTapPreview(){
         view.endEditing(true)
         guard let previewEvent = configurePreviewEvent(),
               let eventVM = OldEventViewModel(with: previewEvent, image:  images[0]) else {return}
         
         let vc = EventViewController(viewModel: eventVM)
         vc.configureExit()
         vc.completion = { [weak self] in
             self?.publishPost(with: previewEvent,completion: { [weak self] event in
                 
                 DispatchQueue.main.async{
                     //                        self?.tabBarController!.selectedIndex = 0
                     self?.navigationController?.popToRootViewController(animated: false)
                     self?.completion?(previewEvent, self?.images[0])
                     
                     
                 }
             })
         }
         
         let navVc = UINavigationController(rootViewController: vc)
         navVc.modalPresentationStyle = .fullScreen
         present(navVc, animated: true)
         
     }
     
     @objc func didDismiss(){
         dismiss(animated: true)
     }
     
     private func configurePreviewEvent (urlStrings:[String] = []) -> Event?{
         
         guard let user = DefaultsManager.shared.getCurrentUser(),
               let gender = user.gender
         else {
             print("user / gender not found")
             return nil
         }
         
         return Event(
             id: IdManager.shared.createEventId(), emojiTitle: nil,
             title: tempEvent.title,
             organisers: [user],
             imageUrlString: urlStrings,
             price: 0,
             startDateTimestamp: tempEvent.startDate.timeIntervalSince1970,
             endDateTimestamp: tempEvent.endDate.timeIntervalSince1970,
             location: tempEvent.location,
             presetTags: [],
             introduction: tempEvent.description,
             additionalDetail: "",
             refundPolicy: "",
             participants: [:],
             comments: [],
             headcount: tempEvent.headcount,
             ownerFcmToken: user.fcmToken,
             eventStatus: .grouping
         )
     }
     
     func publishPost(with previewEvent:Event, completion: @escaping (Event) -> Void){
         
         var imagesData = [Data?]()
         
         for img in images {
             guard let image = img?.sd_resizedImage(with: CGSize(width: 1024, height: 1024), scaleMode: .aspectFill),
                   let data = image.jpegData(compressionQuality: 0.5)
             else {break}
             
             imagesData.append(data)
         }
         
 //        guard let image = images[0]?.sd_resizedImage(with: CGSize(width: 1024, height: 1024), scaleMode: .aspectFill),
 //              let data = image.jpegData(compressionQuality: 0.5)
 //        else {return}
         
         StorageManager.shared.uploadEventImage(id: previewEvent.id, data: imagesData) {[weak self] urlStrings in
             
             guard let event = self?.configurePreviewEvent(urlStrings: urlStrings),
                   let _ = DefaultsManager.shared.getCurrentUser()
             else {return}
             
             DatabaseManager.shared.createEvent(with: event) { done in
                 completion(event)
             }
         }
     }
 }

 */

/* Old Event VC, version 1
class EventViewController: UIViewController {
    
    // MARK: - components
    
    private let image:UIImage?
    var headerImageView:EventHeaderView?
    public var completion: (() -> Void)?
    
    private let collectionView:UICollectionView = {
        let layout = StretchyHeaderLayout()
        let view = UICollectionView(frame: .zero,collectionViewLayout: layout)
        return view
    }()
    
    private let priceLabel: UILabel = {
        let view = UILabel()
        view.text = "Price"
        view.font = .systemFont(ofSize: 16,weight: .bold)
        return view
    }()
    
    private let priceNumberLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let bottomSheet:ParticipantsViewController
    private let selectButton = GAButton(title: "Enroll")
    
    var LikeButton:UIBarButtonItem?
    var shareButton:UIBarButtonItem?
    var isFavourited:Bool = false {
        didSet{
            LikeButton?.tintColor = isFavourited ? .red : .white
            LikeButton?.image = isFavourited ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        }
    }
    
    
    var infoViewModels:[EventInfoCollectionViewCellViewModel]
    
    private let event:Event
    
    private var listener:ListenerRegistration?
    
    
    // MARK: - Init
    init(viewModel vm:OldEventViewModel){
        event = vm.event
        image = vm.image
        infoViewModels = [
            .owner(name: vm.owner),
            .title(title: vm.title),
            .info(title: vm.date.title, subTitle: vm.date.subTitle, type: .time),
            .info(title: vm.location.area, subTitle: vm.location.address, type: .location),
            .extraInfo(title: "About", info: vm.about)
        ]
        priceNumberLabel.text = vm.price
        bottomSheet = ParticipantsViewController(event: event)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        listener?.remove()
        print("eventviewcontroller: released")
    }
    
    func configureBack(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
    }
    
    func configureExit(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: .done, target: self, action: #selector(didTapPublish))
    }
    
    @objc func didTapClose(){
        self.dismiss(animated: true)
    }
    @objc func didTapPublish(){
        guard let completion = completion else {return}
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        completion()
        self.dismiss(animated: true)
    }

    // MARK: - LifeCycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        configureCollectionView()
        configureCollectionViewLayout()
        configureNavBar(shouldBeTransparent: true)
        listener = DatabaseManager.shared.listenForEventChanges(eventId: event.id, completion: {[weak self] event, error in
            guard let event  = event else {return}
            self?.bottomSheet.event = event
        })
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        
        var insets = view.safeAreaInsets
        if let _ = image {
            insets.top = 0
            insets.bottom = insets.bottom+180
        }
        collectionView.contentInset = insets
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBottomSheet()
        if let tabBarController = navigationController?.tabBarController as? TabBarViewController {
            tabBarController.hideTabBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bottomSheet.removeFromParent()
        if let tabBarController = navigationController?.tabBarController as? TabBarViewController {
            tabBarController.showTabBar()
        }
    }
    
    // MARK: - bottomSheet
    
    fileprivate func addBottomSheet() {
        addChild(bottomSheet)
        view.addSubview(bottomSheet.view)
        bottomSheet.didMove(toParent: self)
    }
    
    
    // MARK: - collectionView
    fileprivate func configureCollectionView() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(EventInfoCollectionViewCell.self, forCellWithReuseIdentifier: EventInfoCollectionViewCell.identifier)
        collectionView.register(EventHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventHeaderView.identifier)
        collectionView.register(EventOwnerCollectionViewCell.self, forCellWithReuseIdentifier: EventOwnerCollectionViewCell.identifier)
        
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Layout
    fileprivate func configureCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
            layout.minimumLineSpacing = 10
            layout.estimatedItemSize = CGSize(width: view.width-32, height: 0)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    
    
    @objc private func didTapEnroll(){
        guard let vm = EnrollViewModel(with: event) else {
            print("Fail to create VM")
            return}
        let vc = EnrollViewController(vm: vm)
        present(vc, animated: true)
    }
}

extension EventViewController {
    // MARK: - Like & Share
    
    @objc private func didTapLike(){
        isFavourited.toggle()
        
        if isFavourited {
            DefaultsManager.shared.saveFavouritedEvents(eventID: event.id)
        }else {
            DefaultsManager.shared.removeFromFavouritedEvents(eventID: event.id)
        }
        
    }
    
    
    @objc private func didTapShare(){
        
        let string = event.toString(includeTime: true)
        
        let activityVC = UIActivityViewController(activityItems: [string], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - NavBar
    
    private func configureNavBar(shouldBeTransparent:Bool){
        guard let navBar = navigationController?.navigationBar else {return}
        if navigationItem.rightBarButtonItem == nil {
            
            LikeButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .done, target: self, action: #selector(didTapLike))
            
            shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(didTapShare))
            navigationItem.rightBarButtonItems =  [
                shareButton!,LikeButton!
            ]
            
            isFavourited = DefaultsManager.shared.isEventFavourited(eventID: event.id)
        }
        
        // MARK: - NavBarappearance
        
//        let transparentAppearance = UINavigationBarAppearance()
//        transparentAppearance.configureWithTransparentBackground()
//
//
//        let normalAppearance = UINavigationBarAppearance(idiom: .phone)
//
//        // Apply white color to all the nav bar buttons.
//        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
//        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
//        barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.white]
//        barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.white]
//        barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]
//
//        transparentAppearance.buttonAppearance = barButtonItemAppearance
//        transparentAppearance.backButtonAppearance = barButtonItemAppearance
//        transparentAppearance.doneButtonAppearance = barButtonItemAppearance
//        normalAppearance.buttonAppearance = barButtonItemAppearance
//        normalAppearance.backButtonAppearance = barButtonItemAppearance
//        normalAppearance.doneButtonAppearance = barButtonItemAppearance
//
//
//
//        if shouldBeTransparent {
//            navBar.standardAppearance = transparentAppearance
//            navBar.compactAppearance = transparentAppearance
//            navBar.scrollEdgeAppearance = transparentAppearance
//            LikeButton?.tintColor = isFavourited ? .red: .white
//            shareButton?.tintColor = .white
//        }else {
//            navBar.standardAppearance = normalAppearance
//            navBar.compactAppearance = normalAppearance
//            navBar.scrollEdgeAppearance = normalAppearance
//            LikeButton?.tintColor = isFavourited ? .red: .label
//            shareButton?.tintColor = .label
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
              let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height,
              let navBar = navigationController?.navigationBar,
              let headerView = headerImageView
        else {return}
        let offset = headerView.height - statusBarHeight - (navBar.height)
        
        configureNavBar(shouldBeTransparent: offset>0)
    }
}

extension EventViewController:UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,EventInfoCollectionViewCellDelegate {
    func EventInfoCollectionViewCellDidTapShowMore(_ cell: EventInfoCollectionViewCell) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoViewModels.count
    }
    
    // MARK: - cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return UICollectionViewCell()}
        let padding = layout.sectionInset.left + layout.sectionInset.right
        
        let vm = infoViewModels[indexPath.row]
        
        if case .owner(let name) = vm {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventOwnerCollectionViewCell.identifier, for: indexPath) as! EventOwnerCollectionViewCell
            cell.configure(with: name)
            cell.delegate = self
            cell.widthAnchor.constraint(equalToConstant: view.width-padding).isActive = true
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventInfoCollectionViewCell.identifier, for: indexPath) as! EventInfoCollectionViewCell
        cell.widthAnchor.constraint(equalToConstant: view.width-padding).isActive = true
        cell.configureCell(with:vm)
        cell.delegate = self
        return cell
        
    }
    
    
 
    
    // MARK: - header, footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventHeaderView.identifier, for: indexPath) as! EventHeaderView
        header.image = image
        header.clipsToBounds = true
        headerImageView = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let _ = image {
            return CGSize(width: view.width, height: view.width)
        }else {
            return .zero
        }
        
    }
    
    
}


extension EventViewController:EventOwnerCollectionViewCellDelegate {
    // MARK: - open message view
    func EventOwnerCollectionViewCellDidTapMessage(_ cell: EventOwnerCollectionViewCell, username: String?) {
        
        guard let username = username else {return}
        
        let vc = ChatMessageViewController(targetUsername: username)
        vc.setupNavBar()
        let navVc = UINavigationController(rootViewController: vc)
        navVc.hero.isEnabled = true
        navVc.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .push(direction: .right))
        navVc.modalPresentationStyle = .fullScreen
        present(navVc, animated: true)
    }
    
}

*/


/*
 
 old Event VC, Version 2
 
 
 /*
  
  
  //
  //  EventDetailViewController.swift
  //  Gather Pool
  //
  //  Created by Jason Chau on 2023-02-27.
  //

  import UIKit
  import IGListKit
  import SwipeCellKit

  class EventDetailViewController: UIViewController {
      
      var headerHeight:CGFloat = 0
      
      private let headerView = EventHeaderView()
      
      var navBarAppearance = UINavigationBarAppearance()
      
      private let collectionView :UICollectionView = {
          let layout = UICollectionViewFlowLayout()
          layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
          layout.minimumLineSpacing = 0
          layout.minimumInteritemSpacing = 0
          let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
          view.contentInsetAdjustmentBehavior = .never
          view.contentInset = .init(top: 0, left: 0, bottom: 88, right: 0)
          
          view.register(EventDetailInfoCell.self, forCellWithReuseIdentifier: EventDetailInfoCell.identifier)
          view.register(EventDetailParticipantsCell.self, forCellWithReuseIdentifier: EventDetailParticipantsCell.identifier)
          view.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
          view.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
          view.register(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.identifier)
          
          
          view.register(EventHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventHeaderView.identifier)
          view.register(SectionHeaderRsuableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderRsuableView.identifier)
          view.keyboardDismissMode = .interactive
          return view
          
      }()
      
      private let ownerView:UIView = {
          let view = UIView()
          view.backgroundColor = .systemBackground
          view.clipsToBounds = true
          view.isUserInteractionEnabled = true
          return view
      }()
      
      private let nameLabel:UILabel = {
          let view = UILabel()
          return view
      }()
      
      private let titleLabel:UILabel = {
          let view = UILabel()
          view.font = .robotoSemiBoldFont(ofSize: 30)
          view.numberOfLines = 2
          return view
      }()
      
      private let profileImageView:UIImageView = {
          let view = UIImageView()
          view.clipsToBounds = true
          view.image = .personIcon
          view.tintColor = .lightGray
          return view
      }()
      
      private lazy var messageButton:UIButton = {
          let view = UIButton()
          view.backgroundColor = .systemBackground
          view.setImage(UIImage(systemName: "text.bubble"), for: .normal)
          view.tintColor = .label
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
              
              if let image = vm.image {
                  headerView.image = image
                  headerHeight = view.width
              } else if let imageUrl = vm.imageUrlString {
                  headerView.setImageWithUrl(urlString: imageUrl) {[weak self] image in
                      vm.image = image
                      if let self = self {
                          self.headerHeight = self.view.width
                      }
                  }
              } else {
                  headerHeight = 250
              }
              
              nameLabel.text = vm.organiser?.name
              titleLabel.text = vm.title
              if let profileUrlString = vm.organiser?.profileUrlString {
                  profileImageView.sd_setImage(with: URL(string: profileUrlString))
                  
              }
              navigationItem.title = vm.title
              headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: headerHeight)
              
              VMs = [
                  EventDetailsViewModel(event: vm.event),
                  EventParticipantsViewModel(event: vm.event)
              ]
              
              participantsList = []
              participantsList.append(contentsOf: vm.friends)
              participantsList.append(contentsOf: vm.participantsExcludFriends)
              
              if vm.isOrganiser {
                  configureButtonForOrganiser()
              } else if vm.isJoined {
                  configureButtonForParticipant()
              } else {
                  configureButton()
              }
              
              comments = vm.comments
              
              latestComments = Array(comments.sorted(by: {$0.timestamp > $1.timestamp}).prefix(3))
              
              collectionView.reloadData()
          }
      }
      
      var participantsList:[Participant] = []
      var VMs:[ListDiffable] = []
      
      var comments:[Comment] = []
      var latestComments:[Comment] = []
      var commentText:String? = ""
      private var observer: NSObjectProtocol?
      private var hideObserver: NSObjectProtocol?
      private let bottomOffset:CGFloat = 150
      
      deinit {
          print("EventViewController: released")
      }
      
      override func viewDidLoad() {
          super.viewDidLoad()
          setUpPanBackGestureAndBackButton()
          navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(didTapShare))
          
          view.backgroundColor = .systemBackground
          view.addSubview(headerView)
          view.addSubview(collectionView)
          view.addSubview(buttonStackView)
          view.addSubview(titleLabel)
          view.addSubview(messageButton)
          view.addSubview(ownerView)
          ownerView.addSubview(nameLabel)
          ownerView.addSubview(profileImageView)
          
          observeKeyboardChange()
          
          
          
          collectionView.backgroundColor = .clear
          collectionView.scrollIndicatorInsets = .init(top: -100, left: 0, bottom: 0, right: 0)
          collectionView.delegate = self
          collectionView.dataSource = self
          
          // Add the refresh control as a subview of the collection view layout
          collectionView.addSubview(refreshControl)

          // Adjust the refresh control position to be below the header view
          refreshControl.anchor(top: headerView.bottomAnchor, leading: nil, bottom: nil, trailing: nil)
          refreshControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          
          
          collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)

          ownerView.anchor(top: nil, leading: view.leadingAnchor, bottom: headerView.bottomAnchor, trailing: nil,
                           padding: .init(top: 0, left: 30, bottom: 20, right: 30),size: .init(width: 0, height: 50))
          ownerView.layer.cornerRadius = 25
          
          
          titleLabel.anchor(top: nil, leading: ownerView.leadingAnchor, bottom: ownerView.topAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 20, right: 30))
          
          messageButton.anchor(top: nil, leading: nil, bottom: headerView.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 20, right: 30),size: .init(width: 50, height: 50))
          messageButton.layer.cornerRadius = 25
          messageButton.addTarget(self, action: #selector(didTapChat), for: .touchUpInside)
          
          let profileSize:CGFloat = 40
          profileImageView.anchor(top: ownerView.topAnchor, leading: ownerView.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 5, left: 5, bottom: 0, right: 0),size: .init(width: profileSize, height: profileSize))
          profileImageView.layer.cornerRadius = 20
          nameLabel.anchor(top: ownerView.topAnchor, leading: profileImageView.trailingAnchor, bottom: ownerView.bottomAnchor, trailing: ownerView.trailingAnchor,
                           padding: .init(top: 5, left: 10, bottom: 5, right: 10))
          
          
          
          buttonStackView.anchor(top: collectionView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 5, left: 30, bottom: 40, right: 30),size: .init(width: view.width-60, height: 50))

          
          configureCollectionViewLayout()

      }
      
      
      // MARK: - Bottom Button
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
      
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)

          // Set the navigation bar to be transparent
          navBarAppearance.configureWithTransparentBackground()
          navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
          navigationController?.navigationBar.standardAppearance = navBarAppearance
          navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
          
          if let tabBarController = navigationController?.tabBarController as? TabBarViewController {
              tabBarController.hideTabBar()
          }
      }
      
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
          navigationController?.navigationBar.standardAppearance = UINavigationBarAppearance()
          
          if let tabBarController = navigationController?.tabBarController as? TabBarViewController {
              tabBarController.showTabBar()
          }
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
          AlertManager.shared.showAlert(title: "Oops~",message: "活動不存在或者已取消", buttonText: "Dismiss",cancelText: nil, from: self) {[weak self] in
              self?.navigationController?.popViewController(animated: true)
          }
      }
      
      @objc private func didTapShare(){
          guard let string = viewModel?.event.toString(includeTime: true) else {return}
          let activityVC = UIActivityViewController(activityItems: [string], applicationActivities: nil)
          present(activityVC, animated: true, completion: nil)
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
                let eventRef = viewModel?.event.referencePath else {return}
          
          DatabaseManager.shared.confirmFormEvent(eventID: eventID, eventRef: eventRef) { [weak self] success in
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
          let vc = InviteViewController()
          let navVc = UINavigationController(rootViewController: vc)
          navVc.hero.isEnabled = true
          navVc.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
          navVc.modalPresentationStyle = .fullScreen
          present(navVc, animated: true)
          
          
      }
      
      
      private func editEvent(){
          // MARK: - Edit Event (need modify)
          // edit event does not have event ref, changing date will create another event, need to modify
          let vc = NewPostViewController()
          if let editPost = viewModel?.event.toNewPost() {
              vc.newPost = editPost
              vc.image = viewModel?.image
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
              AlertManager.shared.showAlert(title: "Oops~", message: "Please login to join events", from: self)
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
              
              if let imageUrl = viewModel.imageUrlString, let self = self {
                  
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
          present(vc, animated: true)
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
              
          case 0: // event detail
              let vm = VMs[indexPath.section]
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventDetailInfoCell.identifier, for: indexPath) as! EventDetailInfoCell
              cell.bindViewModel(vm)
              cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
              return cell
              
          case 1: // event participants number
              let vm = VMs[indexPath.section]
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventDetailParticipantsCell.identifier, for: indexPath) as! EventDetailParticipantsCell
              cell.bindViewModel(vm)
              cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
              return cell
              
          case 2: // event comments
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
              cell.heightAnchor.constraint(equalToConstant: 60).isActive = true
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
              return .init(width: view.width, height: headerHeight)
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
              if let vm = VMs[1] as? EventParticipantsViewModel {
                  sectionHeader.configure(with: .init(title: vm.numberOfFriends, buttonText: "全部(\(participantsList.count))", index: 3))
              }
              return sectionHeader
          default:
              return sectionHeader
          }
      }
      
      func scrollViewDidScroll(_ scrollView: UIScrollView) {
          let offset = scrollView.contentOffset.y
          let headerHeight: CGFloat = headerHeight // set the height of your header view here
          let headerBottom = headerHeight - 110
          headerView.alpha = 1.3 - offset/(headerHeight-200)
          
          if offset < 0 { // pull to enlarge photo
              headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: headerHeight-offset)
          }else {
              headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: headerHeight-offset)
          }
          
          
          if offset >= headerBottom {
              // Run code in iOS 15 or later.
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
      
  }

  extension EventDetailViewController:UITextViewDelegate,SectionHeaderReusableViewDelegate {
      func SectionHeaderReusableViewDidTapActionButton(_ view: SectionHeaderRsuableView, button: UIButton) {
          let vc = CollectionListViewController()
          
          let navVc = UINavigationController(rootViewController: vc)
          navVc.hero.isEnabled = true
          navVc.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
          navVc.modalPresentationStyle = .fullScreen
          present(navVc, animated: true)
          
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
                      
                      if let imageUrl = viewModel.imageUrlString, let self = self {
                          
                      }else {
                          viewModel.image = self?.viewModel?.image
                      }
                      self?.commentText = ""
                      self?.viewModel = viewModel
                      self?.collectionView.reloadSections(.init(integer: 2))
                      
                  }
              }
          }
      }
      
      func textViewDidChange(_ textView: UITextView) {
          
          commentText = textView.text
          
          collectionView.performBatchUpdates {
              
          }
          
      }
      
      
      // MARK: - Keyboard Handling
      private func observeKeyboardChange(){
          
          observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {[weak self] notification in
              if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                  self?.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + self!.bottomOffset, right: 0)
                  }
              
          }
          
          hideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
              self?.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self!.bottomOffset, right: 0)
          }
      }
  }

  
  
  */

 
 */
