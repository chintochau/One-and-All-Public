//
//  HeadcountTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-01.
//

import UIKit

import UIKit

protocol HeadcountTableViewCellDelegate:AnyObject {
    func HeadcountTableViewCellDidEndEditing(_ cell:HeadcountTableViewCell, headcount:Headcount)
    func HeadcountTableViewCellDidTapExpand(_ cell :HeadcountTableViewCell, headcount:Headcount)
}

class HeadcountTableViewCell: UITableViewCell {
    static let identifier = "HeadcountTableViewCell"
    
    weak var delegate:HeadcountTableViewCellDelegate?
    
    
    private let headcountLabel:UILabel = {
        let view = UILabel()
        view.text = "成團人數: "
        return view
    }()
    
    private let genderLabel:UILabel = {
        let view = UILabel()
        view.text = "(按性別)"
        
        return view
    }()
    
    let optionalLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        view.text = "(選填)"
        view.isHidden = true
        return view
    }()
    
    private let maleIcon:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .blueColor
        return view
    }()
    
    private let femaleIcon:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .redColor
        return view
    }()
    
    
    let expandButton:UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "lessthan.square"), for: .normal)
        view.tintColor = .secondaryLabel
        return view
    }()
    
    private let minimumTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "最少"
        view.tag = 0
        view.keyboardType = .numberPad
        return view
    }()
    private let maxTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "最多"
        view.tag = 1
        view.keyboardType = .numberPad
        return view
    }()
    private let maleMinField:UITextField = {
        let view = UITextField()
        view.placeholder = "最少"
        view.tag = 2
        view.keyboardType = .numberPad
        return view
    }()
    private let maleMaxField:UITextField = {
        let view = UITextField()
        view.placeholder = "最多"
        view.tag = 3
        view.keyboardType = .numberPad
        return view
    }()
    private let femaleMinField:UITextField = {
        let view = UITextField()
        view.placeholder = "最少"
        view.tag = 4
        view.keyboardType = .numberPad
        return view
    }()
    private let femaleMaxField:UITextField = {
        let view = UITextField()
        view.placeholder = "最多"
        view.tag = 5
        view.keyboardType = .numberPad
        return view
    }()
    
    var cellHeightAnchor:NSLayoutConstraint?
    
    
    var headcount:Headcount?
    
    var isOptional:Bool = false {
        didSet {
            optionalLabel.isHidden = !isOptional
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        selectionStyle = .none
        [headcountLabel,genderLabel,maleIcon,femaleIcon,expandButton,
         minimumTextField,maxTextField,maleMinField,maleMaxField,femaleMinField,femaleMaxField,optionalLabel
        ].forEach{
            contentView.addSubview($0)
            if let field = $0 as? UITextField {
                field.delegate = self
            }
        }
        
        headcountLabel.sizeToFit()
        headcountLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: nil,
                              padding: .init(top: 10, left: 30, bottom: 0, right: 0),size: CGSize(width: headcountLabel.width, height: 0))
        
        optionalLabel.anchor(top: nil, leading: headcountLabel.trailingAnchor, bottom: headcountLabel.bottomAnchor, trailing: nil)
        
        minimumTextField.anchor(top: headcountLabel.topAnchor, leading: nil, bottom: nil, trailing: nil,
                               padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        maxTextField.anchor(top: headcountLabel.topAnchor, leading: minimumTextField.trailingAnchor, bottom: nil, trailing: expandButton.leadingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        
        maleIcon.anchor(top: headcountLabel.topAnchor, leading: nil, bottom: nil, trailing: maxTextField.leadingAnchor,
                         padding: .init(top: 0, left: 10, bottom: 0, right: 70))
        femaleIcon.anchor(top: nil, leading: nil, bottom: contentView.bottomAnchor, trailing: femaleMaxField.leadingAnchor,
                           padding: .init(top: 0, left: 0, bottom: 10, right: 70))
        
        genderLabel.anchor(top: nil, leading: headcountLabel.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 0, bottom: 10, right: 0))
        
        maleMinField.anchor(top: headcountLabel.topAnchor, leading: nil, bottom: nil, trailing: nil,
                               padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        maleMaxField.anchor(top: headcountLabel.topAnchor, leading: maleMinField.trailingAnchor, bottom: nil, trailing: expandButton.leadingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        
        
        femaleMinField.anchor(top: femaleIcon.topAnchor, leading: nil, bottom: nil, trailing: nil,
                               padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        femaleMaxField.anchor(top: femaleIcon.topAnchor, leading: femaleMinField.trailingAnchor, bottom: nil, trailing: expandButton.leadingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        
        expandButton.anchor(top: headcountLabel.topAnchor, leading: nil, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 20))
        expandButton.addTarget(self, action: #selector(didTapExpand), for: .touchUpInside)
        
        
        
    }
    
    public func configureHeadcount(with headcount:Headcount){
        let isExpanded:Bool = headcount.isGenderSpecific
        
        [maleMinField,
         maleMaxField,
         femaleMinField,
         femaleMaxField,
         maleIcon,
         femaleIcon,
         genderLabel
        ].forEach({$0.isHidden = !isExpanded})
        
        [minimumTextField,maxTextField].forEach({$0.isHidden = isExpanded})
        
        expandButton.transform = isExpanded ? .init(rotationAngle: .pi*3/2) : .identity
        cellHeightAnchor = contentView.heightAnchor.constraint(equalToConstant: isExpanded ? 70 : 44)
        cellHeightAnchor?.priority = .defaultHigh
        cellHeightAnchor?.isActive = true
        
        
        // Assign values to text fields
        if let min = headcount.min {
            minimumTextField.text = String(min)
        } else {
            minimumTextField.text = nil
        }

        if let max = headcount.max {
            maxTextField.text = String(max)
        } else {
            maxTextField.text = nil
        }

        if let mMin = headcount.mMin {
            maleMinField.text = String(mMin)
        } else {
            maleMinField.text = nil
        }

        if let mMax = headcount.mMax {
            maleMaxField.text = String(mMax)
        } else {
            maleMaxField.text = nil
        }

        if let fMin = headcount.fMin {
            femaleMinField.text = String(fMin)
        } else {
            femaleMinField.text = nil
        }

        if let fMax = headcount.fMax {
            femaleMaxField.text = String(fMax)
        } else {
            femaleMaxField.text = nil
        }
        
        self.headcount = headcount
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func configureForNewEvent(){
        headcountLabel.text = "人數上限: "
        [minimumTextField,maleMinField,femaleMinField].forEach({$0.removeFromSuperview()})
    }
    
    @objc private func didTapExpand(){
        
        guard let headcount = self.headcount else {return}
        
        var isExpanded = headcount.isGenderSpecific
        
        isExpanded.toggle()
        
        [maleMinField,
         maleMaxField,
         femaleMinField,
         femaleMaxField,
         maleIcon,
         femaleIcon,
         genderLabel].forEach({$0.isHidden = !isExpanded})
        
        [minimumTextField,
         maxTextField].forEach({$0.isHidden = isExpanded})
        
        if isExpanded {
            expandCell()
        }else {
            collapseCell()
        }
        
        layoutIfNeeded()
        delegate?.HeadcountTableViewCellDidTapExpand(self, headcount: self.headcount!)
    }
    
    private func collapseCell(){
        // not gender specific
        cellHeightAnchor?.constant = 44
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.expandButton.transform = .identity
            self?.headcount?.isGenderSpecific = false
            self?.headcount?.fMin = nil
            self?.headcount?.fMax = nil
            self?.headcount?.mMin = nil
            self?.headcount?.mMax = nil
            self?.maleMinField.text = nil
            self?.maleMaxField.text = nil
            self?.femaleMinField.text = nil
            self?.femaleMaxField.text = nil
        }
        
    }
    
    private func expandCell(){
        // gender specific
        cellHeightAnchor?.constant = 70
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.expandButton.transform = .init(rotationAngle: .pi*3/2)
            self?.headcount?.isGenderSpecific = true
            self?.headcount?.max = nil
            self?.headcount?.min = nil
            self?.maxTextField.text = nil
            self?.minimumTextField.text = nil
        }
        
    }
}

extension HeadcountTableViewCell:UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let text:Int? = Int(textField.text ?? "")
        
        switch textField.tag {
        case 0:
            headcount?.min = text
        case 1:
            headcount?.max = text
        case 2:
            headcount?.mMin = text
        case 3:
            headcount?.mMax = text
        case 4:
            headcount?.fMin = text
        case 5:
            headcount?.fMax = text
        default:
            print("invalud tag")
        }
        
        guard let headcount = headcount else {return}
        delegate?.HeadcountTableViewCellDidEndEditing(self, headcount: headcount)
    }
    
}
