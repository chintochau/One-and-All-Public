//
//  SearchResultViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-17.
//

import UIKit
import IGListKit

enum SearchType {
    case events
    case users
}

class SearchResultViewController: UIViewController {
    
    var collectionView:UICollectionView?
    var searchText:String
    private let loadingIndicator:UIActivityIndicatorView = {
        let view  = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.startAnimating()
        view.sizeThatFits(.init(width: 50, height: 50))
        return view
    }()
    
    var searchType:SearchType
    var results:[Any] = []
    
    
    init(searchType: SearchType, searchText:String) {
        self.searchText = searchText
        self.searchType = searchType
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .systemBackground
        title = searchText
        configureCollectionView()
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center
        performSearch()
    }
    
    private func configureCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: view.width, height: 50)
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserEventCell.self, forCellWithReuseIdentifier: UserEventCell.identifier)
        collectionView.register(UserProfileHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderReusableView.identifier)
        collectionView.register(UserMediumCollectionViewCell.self, forCellWithReuseIdentifier: UserMediumCollectionViewCell.identifier)
        
        self.collectionView = collectionView
    }
    
    
    public func performSearch() {
        
        switch searchType{
            
        case .events:
            
            SearchManager.shared.searchForEvents(words: searchText) {[weak self] userEvents in
                DispatchQueue.main.async {
                    self?.results = userEvents
                    self?.collectionView?.reloadData()
                    self?.loadingIndicator.stopAnimating()
                }
            }
        case .users:
            
            SearchManager.shared.searchForUserss(words: searchText, completion: {[weak self] users in
                
                DispatchQueue.main.async {
                    self?.results = users
                    self?.collectionView?.reloadData()
                    self?.loadingIndicator.stopAnimating()
                }
            })
        }
    }
}

extension SearchResultViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch results[indexPath.row] {
        case let vm as UserEvent:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserEventCell.identifier, for: indexPath) as! UserEventCell
            cell.userEvent = vm
            cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
            return cell
            
        case let vm as User:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:UserMediumCollectionViewCell.identifier, for: indexPath ) as! UserMediumCollectionViewCell
            let constraint = cell.widthAnchor.constraint(equalToConstant: (view.width-15)/2)
            constraint.priority = .defaultHigh
            constraint.isActive = true
            cell.user = vm
            return cell
        default:
            fatalError()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch results[indexPath.row] {
        case let vm as UserEvent:
            if let referencePath = vm.referencePath {
                presentEventDetailViewController(eventID: vm.id, eventRef: referencePath)
                
            }
        case let vm as User:
            let vc = UserProfileViewController(user: vm)
            vc.enableSwipeBackNavigation()
            navigationController?.pushViewController(vc, animated: true)
            
            
        default:
            break
        }
        
    }
}
