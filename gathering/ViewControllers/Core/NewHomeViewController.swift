//
//  NewHomeViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import UIKit
import Hero
import IGListKit

class NewHomeViewController: UIViewController{
    // MARK: - Components
    private var collectionView:UICollectionView?
    private let refreshControl = UIRefreshControl()
    
    
    private let searchController:UISearchController = {
        let view = UISearchController(searchResultsController: HomeSearchResultTableViewController())
        view.searchBar.placeholder = "搜尋活動/興趣"
        view.hidesBottomBarWhenPushed = true
        view.obscuresBackgroundDuringPresentation = true
        view.showsSearchResultsController = true
        return view
    }()
    
    private let titleLabel : UILabel = {
        let view = UILabel()
        view.text = "One&All"
        view.font = .helveticaBold(ofSize: 24)
        view.textColor = .label
        return view
    }()
    
    private lazy var locationButton:UIButton = {
        let view = UIButton()
        view.titleLabel?.font = .systemFont(ofSize: 16)
        view.setTitleColor(.label, for: .normal)
        view.addTarget(self, action: #selector(presentLocationSelection), for: .touchUpInside)
        return view
    }()
    
    private let headerView :UIView = {
        let view = UIView()
        return view
    }()
    
    private let menuBar:MenuBar = {
        let view = MenuBar()
        var array = ["全部活動"]
        array.append(contentsOf: HomeCategoryType.allCases.map({$0.rawValue}))
        view.items = array
        return view
    }()
    
    
    
    // MARK: - Class members
    let viewModel = HomeViewModel.shared
    var currentCell:BasicEventCollectionViewCell?
    private let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
    let eventsPerPage = 7
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let userRegion = UserDefaults.standard.string(forKey: UserDefaultsType.region.rawValue) {
            locationButton.setTitle(userRegion, for: .normal)
        }else {
            presentLocationSelection()
        }
        
        
        configureNavBar()
        configureCollectionView()
        fetchInitialDataAndRefresh()
        navigationItem.hidesSearchBarWhenScrolling = false
        configureMenuBar()
        self.extendedLayoutIncludesOpaqueBars = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPullToRefresh), name: Notification.Name("userStateRefreshed"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    private func configureCollectionView(){
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout:layout)
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HomeSectionCollectionViewCell.self, forCellWithReuseIdentifier: HomeSectionCollectionViewCell.identifier)
        self.collectionView = collectionView
    }
    
    
    @objc private func didPullToRefresh(){
        fetchInitialDataAndRefresh {[weak self] in
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Fetch Data
    private func fetchInitialDataAndRefresh(completion: (() -> (Void))? = nil ){
        viewModel.fetchInitialData(perPage: eventsPerPage) { [weak self] events in
            self?.collectionView?.reloadData()
        }
    }
    
    private func fetchMoreData(completion: (() -> (Void))? = nil ){
//        viewModel.fetchMoreData(perPage: eventsPerPage) {[weak self] events in
//            guard let self = self else { return }
//            self.adapter.performUpdates(animated: true)
//            completion?()
//        }
    }
    
}

extension NewHomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x/view.frame.width
        menuBar.collectionView.selectItem(at: .init(row: Int(index), section: 0), animated: false, scrollPosition: [])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuBar.items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSectionCollectionViewCell.identifier, for: indexPath) as! HomeSectionCollectionViewCell
        cell.cellIndex = indexPath.row
        cell.viewController = self
        
        switch indexPath.row {
        case 0:
            cell.category = nil
        default:
            cell.category = HomeCategoryType.allCases[indexPath.row-1]
            cell.loadMoreDataFor(eventType: HomeCategoryType.allCases[indexPath.row-1])
        }
        
//        if indexPath.row == 0 {
//            cell.category = nil
//        } else {
//            cell.category = EventType.allCases[indexPath.row-1]
//            cell.loadMoreDataFor(eventType: EventType.allCases[indexPath.row-1])
//        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.width, height: view.height)
    }
}

extension NewHomeViewController:UIScrollViewDelegate  {
    
    // MARK: - NavBar
    
    fileprivate func configureNavBar() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.hidesBarsOnSwipe = true
        navigationItem.rightBarButtonItems = [
            .init(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(didTapAdd)),
            .init(image: UIImage(systemName: "bell"), style: .done, target: self, action: #selector(didTapNotification)),UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(didTapSearch))
        ]
        
        
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(locationButton)
        navigationItem.titleView = headerView
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 0, y: 0, width: titleLabel.width, height: 44)
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
        locationButton.sizeToFit()
        locationButton.frame = CGRect(x: titleLabel.right+10, y: 0, width: titleLabel.width, height: 44)
        
        
        if let resultVC = searchController.searchResultsController as? HomeSearchResultTableViewController {
            resultVC.delegate = self
        }
    }
    
    @objc private func didTapSearch() {
        
        
        present(searchController, animated: true, completion: nil)
        searchController.searchResultsUpdater = searchController.searchResultsController as? HomeSearchResultTableViewController
    }
    
    func scrollToMenuIndex(menuIndex:Int){
        collectionView?.scrollToItem(at: .init(row: menuIndex, section: 0), at: [], animated: true)
    }

    
    @objc private func didTapNotification(){
        let vc = NotificationsViewController.shared
        vc.setUpPanBackGestureAndBackButton()
        presentModallyWithHero(vc)
    }
    
    @objc private func didTapChat(){
        let vc = ChatMainViewController()
        let navVc = UINavigationController(rootViewController: vc)
        navVc.hero.isEnabled = true
        navVc.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
        navVc.modalPresentationStyle = .fullScreen
        present(navVc, animated: true)
    }
    
    @objc private func didTapAdd(){
//        tabBarController?.showCategoryViewController()
        showNewPostViewController()
    }
    
    @objc private func presentLocationSelection(){
        return
        
        // MARK: - select location
        
        let vc = LocationPickerViewController()
        
        if let _ = UserDefaults.standard.string(forKey: UserDefaultsType.region.rawValue) {
            
        }else {
            vc.modalPresentationStyle = .fullScreen
        }
        
        vc.completion = {
            if let location = UserDefaults.standard.string(forKey: UserDefaultsType.region.rawValue) {
                self.locationButton.setTitle(location, for: .normal)
                self.didPullToRefresh()
            }
            
        }
        
        
        present(vc, animated: true)
        
    }
    
    
    // MARK: - Swipe Bar
    
    fileprivate func configureMenuBar() {
        let swipeView = menuBar
        menuBar.homeController = self
        let navBarBackgroundView = UIView()
        view.addSubview(navBarBackgroundView)
        view.addSubview(swipeView)

        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        navBarBackgroundView.addSubview(visualEffectView)
        visualEffectView.fillSuperview()

        navBarBackgroundView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: swipeView.bottomAnchor, trailing: view.trailingAnchor)
        swipeView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor,size: .init(width: 0, height: 38))

        setupHorizontalBarView()
    }
    
    private func setupHorizontalBarView(){
        let horizontalBar = UIView()
        horizontalBar.backgroundColor = .mainColor
    }
    
    
}

extension NewHomeViewController:HomeSearchResultTableViewControllerDelegate {
    func HomeSearchResultTableViewControllerDidChooseResult(_ view: HomeSearchResultTableViewController, result: HomeSearchResultType,searchText:String) {
        // MARK: - Handle Search
        
        switch result {
        case .organiseEvent:
            print("Organise Event")
        case .searchEvent:
            searchController.searchBar.resignFirstResponder()
            let vc = SearchResultViewController(searchType: .events,searchText: searchText)
            vc.setUpPanBackGestureAndBackButton()
            presentModallyWithHero(vc)
        case .groupUp:
            showNewPostViewController(eventName: searchText)
        case .searchPeople:
            searchController.searchBar.resignFirstResponder()
            let vc = SearchResultViewController(searchType:.users,searchText: searchText)
            vc.setUpPanBackGestureAndBackButton()
            presentModallyWithHero(vc)
            
        }
    }
    
    
}
