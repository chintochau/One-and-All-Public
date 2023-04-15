//
//  MenuBar.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-18.
//

import UIKit

protocol MenuBarDelegate: AnyObject{
    func MenuBarDidTapItem(_ menu:MenuBar, menuIndex:Int)
    
}

class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    

    var homeController:NewHomeViewController?
    weak var delegate:MenuBarDelegate?
    
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = .init(width: 50, height: 30)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(MenuBarCell.self, forCellWithReuseIdentifier: MenuBarCell.identifier)
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        return view
    }()
    
    
    
    var leftIndicatorAnchor:NSLayoutConstraint!
    var rightindicatorAnchor:NSLayoutConstraint!
    
    
    var items:[String] = [] {
        didSet{
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(collectionView)
        collectionView.fillSuperview()
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.selectItem(at: .init(row: 0, section: 0), animated: false, scrollPosition: [])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuBarCell.identifier, for: indexPath) as! MenuBarCell
        cell.heightAnchor.constraint(equalToConstant: height-10).isActive = true
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        
        homeController?.scrollToMenuIndex(menuIndex: indexPath.row)
        delegate?.MenuBarDidTapItem(self, menuIndex:indexPath.row)
        
        
    }
    

}


class MenuBarCell:UICollectionViewCell {
    static let identifier = "MenuBarCell"
    
    private let selectedIndicator:UIView = {
        let view = UIView()
        view.backgroundColor = .mainColor
        view.isHidden = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            itemLabel.textColor = isSelected ? .label: .darkGray
            selectedIndicator.isHidden = !isSelected
        }
    }
    
    private let itemLabel:UILabel = {
        let view = UILabel()
        view.font = .righteousFont(ofSize: 16)
        view.textColor = .darkGray
        
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(itemLabel)
        addSubview(selectedIndicator)
        self.layer.cornerRadius = 10
        itemLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        selectedIndicator.anchor(top: bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: .init(width: 0, height: 3))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure(with name:String) {
        itemLabel.text = name
    }
    
}
