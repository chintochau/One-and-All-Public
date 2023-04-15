//
//  LocationPickerTableViewCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-04.
//

import UIKit

protocol LocationPickerTableViewCellDelegate:AnyObject {
    func didSelectLocation(_ cell: LocationPickerTableViewCell, didSelectObject object: Any)
    func didStartEditing(_ cell: LocationPickerTableViewCell,textField:UITextField)
    func didChangeText(_ cell: LocationPickerTableViewCell,textField:UITextField)
    func didEndEditing(_ cell: LocationPickerTableViewCell,textField:UITextField)
    
}

class LocationPickerTableViewCell: UITableViewCell {
    
    static let identifier = "LocationPickerTableViewCell"
    
    
    weak var delegate: LocationPickerTableViewCellDelegate?
    
    
    
    var searchSuggestions = [String]()
    
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoMedium(ofSize: 16)
        return view
    }()
    
    
    
    let optionalLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        view.text = "(選填)"
        return view
    }()
    
    private let searchTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "搜尋其他地點"
        view.layer.borderColor = UIColor.darkMainColor.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .darkMainColor
        searchIcon.frame = CGRect(x: 12, y: 12, width: 25, height: 25)
        searchIcon.contentMode = .scaleAspectFit
        
        let  leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        leftView.layer.borderColor = UIColor.darkMainColor.cgColor
        leftView.layer.borderWidth = 1
        leftView.addSubview(searchIcon)
        leftView.backgroundColor = .lightFillColor
        
        view.leftView = leftView
        view.leftViewMode = .always
        
        
        return view
    }()
    
    private let subInfoTextLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .robotoRegularFont(ofSize: 14)
        view.numberOfLines = 1
        return view
    }()
    
    
    private let collectionView: UICollectionView = {
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 30, bottom: 0, right: 0)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.estimatedItemSize = CGSize(width: 50, height: 30)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
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
                searchTextField.text = object.name == Location.toBeConfirmed.name ? nil : object.name
                subInfoTextLabel.text = object.address
            }
        }
    }
    private var selectedIndex: Int? = 0
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        [collectionView,titleLabel,searchTextField,subInfoTextLabel,optionalLabel].forEach({contentView.addSubview($0)})
        contentView.addSubview(searchTextField)
        
        
        titleLabel.sizeToFit()
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: nil,
                          padding: .init(top: 5, left: 30, bottom: 0, right: 0),size: .init(width: titleLabel.width, height: 0))
        
        optionalLabel.anchor(top: nil, leading: titleLabel.trailingAnchor, bottom: titleLabel.bottomAnchor, trailing: nil)
        
        
        
        
        // set up the search suggestion delegate
        searchTextField.delegate = self
        
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.anchor(top: titleLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 9, left: 0, bottom: 0, right: 0),size: .init(width: 0, height: 40)
        )
        
        

        searchTextField.anchor(top: collectionView.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,padding: .init(top: 9, left: 30, bottom: 0, right: 30),
                               size: .init(width: 0, height: 50))
        subInfoTextLabel.anchor(top: nil, leading: searchTextField.leadingAnchor, bottom: searchTextField.bottomAnchor, trailing: searchTextField.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 0 ))
        
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
    
    func selectInitialCell(){
        if let selectedIndex = selectedIndex {
            collectionView.selectItem(at: .init(row: selectedIndex, section: 0), animated: false, scrollPosition: [])
        }
    }
    
    
}

extension LocationPickerTableViewCell:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let selected = selectedIndex {
            collectionView.deselectItem(at: .init(row: selected, section: 0), animated: false)
            selectedIndex = nil
        }
        
        delegate?.didStartEditing(self, textField: textField)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.didChangeText(self, textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didEndEditing(self, textField: textField)
    }
    
    
}

extension LocationPickerTableViewCell: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterButtonCollectionViewCell.identifier, for: indexPath) as! FilterButtonCollectionViewCell
        let object = objects[indexPath.row]
        cell.configure(with: object)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = true
        self.selectedObject = object
        self.selectedIndex = indexPath.row
        delegate?.didSelectLocation(self, didSelectObject: object)
    }
}
