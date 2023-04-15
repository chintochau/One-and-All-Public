//
//  HomeSectionCollectionViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-18.
//

import UIKit
import IGListKit

class HomeSectionCollectionViewCell: UICollectionViewCell, ListAdapterDataSource, ListAdapterDelegate {
    
    static let identifier = "HomeSectionCollectionViewCell"
    
    
    var viewController:UIViewController? {
        didSet {
            adapter.viewController = viewController
        }
    }
    var cellIndex:Int = 0
    var category:HomeCategoryType? {
        didSet {
                adapter.performUpdates(animated: true)
        }
    }
    private let viewModel = HomeViewModel.shared
    private var collectionView:UICollectionView?
    let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
    private let refreshControl = UIRefreshControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func fetchInitialDataAndRefresh(completion: (() -> (Void))? = nil ){
        viewModel.fetchInitialData(perPage: 7) { [weak self] events in
            self?.adapter.reloadData()
            completion?()
        }
    }
    
    
    
    
    public func loadMoreDataFor(eventType:HomeCategoryType){
        
        switch eventType {
        case .organisation:
            fetchOrganisations()
        case .mentor:
            self.viewModel.fetchMentors {
                self.adapter.performUpdates(animated: true)
            }
        default:
            if viewModel.getItemsFor(categoryType: eventType).count < 7 {
                fetchMoreData()
            }
        }
    }
    
    
    private func fetchOrganisations(){
        self.viewModel.fetchOrganisations {
            self.adapter.performUpdates(animated: true)
        }
    }
    
    private func fetchMoreData(completion: (() -> (Void))? = nil ){
        viewModel.fetchMoreData(perPage: 7) {[weak self] events in
            guard let self = self else { return }
            self.adapter.performUpdates(animated: true)
            completion?()
        }
    }
    
    @objc private func didPullToRefresh(){
        fetchInitialDataAndRefresh {[weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    
     
    fileprivate func setupCollectionView() {
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
        
        collectionView.backgroundColor = .secondarySystemBackground
        addSubview(collectionView)
        collectionView.contentInset = .init(top: 33, left: 0, bottom: 0, right: 0)
        collectionView.fillSuperview()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        switch category {
        case .none:
            return viewModel.items
        case .organisation:
            return viewModel.organisations
        case .some(let type):
            return viewModel.getItemsFor(categoryType: type)
            
        }
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
        if index == viewModel.items.count - 1, viewModel.items.count > 6 {
            fetchMoreData()
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {
        
    }
    
}
