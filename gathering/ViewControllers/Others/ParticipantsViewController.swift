//
//  ParticipantsViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-29.
//

import UIKit



class ParticipantsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Components
    private let tableView:UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return view
    }()
    
    private var headerView:ParticipantsViewHeaderView?
    
    // MARK: - Class members
    private let eventID:String
    var event:Event {
        didSet {
            headerView?.viewModel = .init(event: event)
            self.models = event.participants.values.map({ participant in
                return participant
            })
            tableView.reloadData()
        }
    }
    private let headerHeight:CGFloat = 110
    
    var models:[Participant]
    var openProfile:(() -> Void)?
    
    // MARK: - Init
    init (event:Event) {
        self.event = event
        self.eventID = event.id
        self.models = event.participants.values.map({ participant in
            return participant
        })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: view.height-headerHeight, width: view.width, height: view.height)
        configureHeaderView()
        setupTableView()
        addGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    
    // MARK: - ViewModels
    
    fileprivate func fetchParticipants() {
        DatabaseManager.shared.fetchParticipants(with:eventID){[weak self] participants in
            guard let participants = participants else {return}
            self?.models = participants
        }
    }
    
    // MARK: - HeaderView
    fileprivate func configureHeaderView() {
        let header = ParticipantsViewHeaderView()
        header.viewModel = EventCellViewModel(event: event)
        view.addSubview(header)
        header.frame = CGRect(x: 0, y: 0, width: view.width, height: headerHeight)
        header.delegate = self
        headerView = header
    }

    
    // MARK: - Background View
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .regular)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
    // MARK: - Gesture
    fileprivate func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        guard let headerView = headerView else {return}
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        tapGesture.numberOfTapsRequired = 1
        headerView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Tap Gesture
    @objc func tapGesture(sender: UITapGestureRecognizer){
        
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.view.frame = CGRect(x: 0, y: self?.view.width ?? 0, width: self?.view.width ?? 0, height: self?.view.height ?? 0)
        }
    }
    
    // MARK: - Pan Gesture adjust height
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let y = view.frame.minY
        let swipeSpeed = sender.velocity(in: view).y
        
        switch sender.state{
        case .began:
            break
        case .changed:
            if y < 100 {
                break
            }
            view.frame = CGRect(
                x: 0,
                y: y + (translation.y),
                width: view.width,
                height: view.height)
            sender.setTranslation(.zero, in: view)
        case .ended:
            let initialY = view.height-headerHeight
            var finalY:CGFloat
            
            if y < view.height/3.5 {
                // upper half
                if swipeSpeed > 1000 {
                    finalY = view.width
                } else {
                    finalY = 100
                }
            }else if y > view.height*2/3 {
                // lower half
                if swipeSpeed < -1000 {
                    finalY = view.width
                }else {
                    finalY = initialY
                    
                }
            }else {
                // middle range
                switch swipeSpeed {
                case 1000...:
                    finalY = initialY
                case ...(-1000):
                    finalY = 100
                case -1000...1000:
                    finalY = view.width
                default:
                    finalY = view.width
                }
                
            }
            UIView.animate(withDuration: 0.2) {[weak self] in
                self?.view.frame = CGRect(x: 0, y: finalY, width: self?.view.width ?? 0, height: self?.view.height ?? 0)
            }
            sender.setTranslation(.zero, in: view)
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard  let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return false}
            
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        if (tableView.contentOffset.y == 0 && direction > 0 || y == view.height-headerHeight)  {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        return false
    }
    
    
}

extension ParticipantsViewController:UITableViewDelegate,UITableViewDataSource {
    // MARK: - TableView
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        guard let headerView = headerView else {return}
        tableView.frame = CGRect(x: 0, y: headerView.bottom, width: view.width, height: view.height-headerView.height)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    // MARK: - Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = models.sorted(by: { $0.joinStatus.rawValue > $1.joinStatus.rawValue
        })[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
        cell.configure(with: vm)
        
        return cell
    }
    
    // MARK: - Select Cell
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.row]
        
        if let user = User(with: model) {
            let vc = UserProfileViewController(user: user)
            self.present(vc, animated: true)
        }
        
    }
    
    
}

extension ParticipantsViewController:ParticipantsViewHeaderViewDelegate {
    // MARK: - Enroll Event
    func didTapEdit(_ view: ParticipantsViewHeaderView) {
        print("Tapped Edit")
    }
    
    func didTapQuit(_ view: ParticipantsViewHeaderView) {
        DatabaseManager.shared.unregisterEvent(event: event) { success in
            
        }
    }
    
    func didTapEnroll(_ view: ParticipantsViewHeaderView) {
        
        if !AuthManager.shared.isSignedIn {
            let vc = UIAlertController(title: "Oops~", message: "Please login to join events", preferredStyle: .alert)
            let action = UIAlertAction(title: "dismiss", style: .default)
            vc.addAction(action)
            present(vc, animated: true)
        }
        
        guard let vm = EnrollViewModel(with: event) else {
            print("Fail to create VM")
            return}
        
        let vc = EnrollViewController(vm: vm)
        vc.completion = {[weak self] in
            self?.view.frame = CGRect(x: 0, y: (self?.view.width)!, width: self?.view.width ?? 0, height: self?.view.height ?? 0)

        }
        
        present(vc, animated: true)
    }
}
