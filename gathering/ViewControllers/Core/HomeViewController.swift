//
//  HomeViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import UIKit
import Hero
import IGListKit

class HomeViewController: UIViewController{
    // MARK: - Components
    private var collectionView:UICollectionView?
    private let refreshControl = UIRefreshControl()
    
    
    private let searchController:UISearchController = {
        let view = UISearchController(searchResultsController: HomeSearchResultTableViewController())
        view.searchBar.placeholder = "搜尋活動"
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
    
    private let headerView :UIView = {
        let view = UIView()
        return view
    }()
    
    private let menuBar:MenuBar = {
        let view = MenuBar()
        view.items.append(contentsOf: HomeCategoryType.allCases.map({$0.rawValue}))
        return view
    }()
    
    
    
    // MARK: - Class members
    private var viewModel = HomeViewModel()
    var currentCell:BasicEventCollectionViewCell?
    private let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
    let eventsPerPage = 7
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureCollectionView()
        fetchInitialDataAndRefresh()
        navigationItem.hidesSearchBarWhenScrolling = false
        configureMenuBar()
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    private func configureCollectionView(){
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
            // item
            let eventItem = NSCollectionLayoutItem(
                layoutSize:
                    NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(10))
            )
            // group
            let eventGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize:
                    NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(30)),
                subitem: eventItem,
                count: 1
            )
            eventGroup.edgeSpacing = .init(leading: .fixed(0), top: .fixed(5), trailing: .fixed(0), bottom: .fixed(5))
            //Header
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(44)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            sectionHeader.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
            let section = NSCollectionLayoutSection(group: eventGroup)
            // MARK: - add header to first section if needed
            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = index == 0 ? [] : []
            section.orthogonalScrollingBehavior = .groupPagingCentered
            return section
        }))
        
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = .init(top:38, left: 0, bottom: 20, right: 0)
        collectionView.backgroundColor = .secondarySystemBackground
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        self.collectionView = collectionView
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.delegate = self
        adapter.viewController = self
        adapter.scrollViewDelegate = self

    }
    
    
    @objc private func didPullToRefresh(){
        fetchInitialDataAndRefresh {[weak self] in
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Fetch Data
    private func fetchInitialDataAndRefresh(completion: (() -> (Void))? = nil ){
        viewModel.fetchInitialData(perPage: eventsPerPage) { [weak self] events in
            self?.adapter.reloadData()
            completion?()
        }
    }
    
    private func fetchMoreData(completion: (() -> (Void))? = nil ){
        viewModel.fetchMoreData(perPage: eventsPerPage) {[weak self] events in
            guard let self = self else { return }
            self.adapter.performUpdates(animated: true)
            completion?()
        }
    }
    
}
 // MARK: - List Adapter
extension HomeViewController: ListAdapterDataSource,ListAdapterDelegate {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel.items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case _ as EventCellViewModel:
            return EventSectionController()
        default:
            return HomeSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {
        if index == viewModel.items.count - 1 {
            fetchMoreData()
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {
    }
}


extension HomeViewController:UIScrollViewDelegate  {
    
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
        navigationItem.titleView = headerView
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 0, y: 0, width: titleLabel.width, height: 44)
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
        
        
        
        if let resultVC = searchController.searchResultsController as? HomeSearchResultTableViewController {
            
            resultVC.delegate = self
        }
        
    }
    
    @objc private func didTapSearch() {
        present(searchController, animated: true, completion: nil)
        searchController.searchResultsUpdater = searchController.searchResultsController as? HomeSearchResultTableViewController
    }

    
    @objc private func didTapNotification(){
        let vc = NotificationsViewController()
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
        tabBarController?.showCategoryViewController()
    }
    
    
    // MARK: - Swipe Bar
    
    fileprivate func configureMenuBar() {
        let swipeView = menuBar
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

extension HomeViewController:HomeSearchResultTableViewControllerDelegate {
    func HomeSearchResultTableViewControllerDidChooseResult(_ view: HomeSearchResultTableViewController, result: HomeSearchResultType,searchText:String) {
        
        switch result {
        case .organiseEvent:
            
            showNewPostViewController(eventName: searchText)
            
        case .searchEvent:
            let vc = SearchResultViewController(searchType: .events, searchText: searchText)
            
            vc.setUpPanBackGestureAndBackButton()
            presentModallyWithHero(vc)
        case .groupUp:
            print("Group Up")
        case .searchPeople:
            print("Search people")
        }
    }
    
    
}
