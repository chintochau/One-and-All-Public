//
//  PhotoGridTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-16.
//

import UIKit

protocol PhotoGridTableViewCellDelegate:AnyObject {
    func PhotoGridTableViewCellSelectImage(_ view:PhotoGridTableViewCell, cell:PhotoCollectionViewCell, index:Int)
}
class PhotoGridTableViewCell: UITableViewCell {

    static let identifier = "PhotoGridTableViewCell"
    
    weak var delegate: PhotoGridTableViewCellDelegate?
    
    var images:[UIImage] = [] {
        didSet {
            let imageCount = min(images.count,3)
            
            collectionView.reloadData()
        }
    }
    
    var cells = [UICollectionViewCell]()
    
    var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .secondarySystemBackground
        view.showsHorizontalScrollIndicator = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        registerCell()
        
        collectionView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,size: CGSize(width: 0, height: (contentView.width/2)))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func registerCell(){
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
    }
    
    
    
}

extension PhotoGridTableViewCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        cell.image = images.first
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = contentView.height-10
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        delegate?.PhotoGridTableViewCellSelectImage(self, cell: cell, index: indexPath.row)
        
    }
}

