//
//  HorizontalCollectionTableViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-24.
//
import UIKit

protocol HorizontalCollectionViewCellDelegate: AnyObject {
    func horizontalCollectionViewCell(_ cell: HorizontalCollectionView, didSelectObject object: Any)
}

class HorizontalCollectionView: UITableViewCell {
    
    static let identifier = "HorizontalCollectionViewTableViewCell"
    
    
    weak var delegate: HorizontalCollectionViewCellDelegate?
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let infoTextLabel:UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.textAlignment = .right
        return view
    }()
    
    
    let optionalLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        view.text = "(選填)"
        return view
    }()
    
    private let subInfoTextLabel:UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.textAlignment = .right
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 2
        return view
    }()
    
    private let bottomLine:UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 0)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.estimatedItemSize = CGSize(width: 50, height: 30)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.register(FilterButtonCollectionViewCell.self, forCellWithReuseIdentifier: FilterButtonCollectionViewCell.identifier)
        return view
    }()
    
    var isOptional = false {
        didSet {
            optionalLabel.isHidden = !isOptional
        }
    }
    
    // MARK: - Class members
    private var objects: [Any] = []
    private var selectedObject:Any? {
        didSet {
            if let object = selectedObject as? Location {
                infoTextLabel.text = object.name
                subInfoTextLabel.text = object.address
            }
        }
    }
    private var selectedIndex: Int?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        [collectionView,titleLabel,infoTextLabel,bottomLine,subInfoTextLabel,optionalLabel].forEach({contentView.addSubview($0)})
        
        titleLabel.sizeToFit()
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: nil,
                          padding: .init(top: 5, left: 20, bottom: 0, right: 0),size: .init(width: titleLabel.width, height: 0))
        
        optionalLabel.anchor(top: nil, leading: titleLabel.trailingAnchor, bottom: titleLabel.bottomAnchor, trailing: nil)
        
        infoTextLabel.anchor(top: titleLabel.topAnchor, leading: nil, bottom: nil, trailing: contentView.trailingAnchor,
                             padding: .init(top: 0, left: 0, bottom: 0, right: 20))
        
        subInfoTextLabel.anchor(top: infoTextLabel.bottomAnchor, leading: titleLabel.trailingAnchor, bottom: nil, trailing: infoTextLabel.trailingAnchor)
        
        bottomLine.anchor(top: infoTextLabel.bottomAnchor, leading: infoTextLabel.leadingAnchor, bottom: nil, trailing: infoTextLabel.trailingAnchor,size: .init(width: 0, height: 1))
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        collectionView.anchor(top: subInfoTextLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,padding: .init(top: 15, left: 0, bottom: 5, right: 0),
                              size: .init(width: 0, height: 40)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configuration
    
    func configure(title :String,selectedObject:Any, with objects: [Any]) {
        self.objects = objects
        self.selectedObject = selectedObject
        titleLabel.text = title
        collectionView.reloadData()
        
    }
    
    
}

// MARK: - UICollectionViewDataSource

extension HorizontalCollectionView: UICollectionViewDataSource {
    
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

// MARK: - UICollectionViewDelegateFlowLayout

extension HorizontalCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = true
        self.selectedObject = object
        delegate?.horizontalCollectionViewCell(self, didSelectObject: object)
    }
    
}
