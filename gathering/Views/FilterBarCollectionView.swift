//
//  FilterBarCollectionView.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-24.
//

import UIKit

class FilterBarCollectionView: UICollectionView {

    
    // MARK: - Class Members
    var objects:[Any] = [] {
        didSet{
            reloadData()
        }
    }
    var selectedObject:Any?
    
    // MARK: - Init
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 30, bottom: 0, right: 0)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = CGSize(width: 50, height: 30)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        super.init(frame: .zero, collectionViewLayout: layout)
        showsHorizontalScrollIndicator = false
        register(FilterButtonCollectionViewCell.self, forCellWithReuseIdentifier: FilterButtonCollectionViewCell.identifier)
        backgroundColor = .clear
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension FilterBarCollectionView:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterButtonCollectionViewCell.identifier, for: indexPath) as! FilterButtonCollectionViewCell
        
        let object = objects[indexPath.row]
        cell.configure(with: object)
        
        return cell
    }
    
    
}
