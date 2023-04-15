//
//  CollectionListViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-13.
//
import UIKit

class CollectionListViewController: UIViewController {
    
    // MARK: - Properties
    
    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: 0, height: 50)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return view
    }()
    
    
    
    private var textViewBottomConstraint: NSLayoutConstraint!
    
    var items:[Any] = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.alwaysBounceVertical = true
        
        view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
    
    
    private func loadData() {
        // Load user data here, and assign to both users and filteredUsers arrays
    }
    
    
}

// MARK: - UICollectionViewDataSource

extension CollectionListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let items = items as? [Comment] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
            cell.bindViewModel(items[indexPath.row])
            cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
            return cell
            
        }else if let items = items as? [Participant] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.identifier, for: indexPath) as! UserCollectionViewCell
            cell.bindViewModel(items[indexPath.row])
            cell.widthAnchor.constraint(equalToConstant: view.width).isActive = true
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}


