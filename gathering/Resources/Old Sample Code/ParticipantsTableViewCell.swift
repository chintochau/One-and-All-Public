//
//  ParticipantsTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-02.
//

import Foundation
import UIKit

protocol ParticipantsTableViewCellDelegate:AnyObject {
    func ParticipantsTableViewCellTextViewDidChange(_ cell:ParticipantsTableViewCell,_ textView:UITextView)
    func ParticipantsTableViewCellTextViewDidEndEditing(_ cell:ParticipantsTableViewCell,_ textView:UITextView,participants:[String:Participant])
}

class ParticipantsTableViewCell:UITableViewCell {
    
    
    static let identifier = "ParticipantsTableViewCell"
    
    weak var delegate:ParticipantsTableViewCellDelegate?
    
    private let stackView:UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.axis = .vertical
        return view
    }()
    
    let titleLabel:UILabel = {
        let view = UILabel()
        view.text = "接龍:"
        return view
    }()
    
    let countLabel:UILabel = {
        let view = UILabel()
        view.text = "人數: 1"
        return view
    }()
    
    
    let optionalLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        view.text = "(選填)"
        return view
    }()
    
    let userLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let userImageView:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .blueColor
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let textView:UITextView = {
        let view = UITextView()
        view.textColor = .label
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 20)
        view.isScrollEnabled = false
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()
    
    
    private let redIcon:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .redColor
        return view
    }()
    
    private let blueIcon:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .blueColor
        return view
    }()
    private let blueNumber:UILabel = {
        let view = UILabel()
        view.text = "0"
        return view
    }()
    private let redNumber:UILabel = {
        let view = UILabel()
        view.text = "0"
        return view
    }()
    
    
    var buttons = [UIButton]()
    var isOptional:Bool = false {
        didSet {
            optionalLabel.isHidden = !isOptional
        }
    }
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [textView,
         titleLabel,
         countLabel,
         stackView,
         userLabel,
         userImageView,
         redIcon,
         blueIcon,
         blueNumber,
         redNumber,
        optionalLabel].forEach({contentView.addSubview($0)})
        [titleLabel,
         countLabel].forEach({$0.sizeToFit()})
        textView.delegate = self
        selectionStyle = .none
        
        
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 5, left: 30, bottom: 0, right: 0))
        
        optionalLabel.anchor(top: nil, leading: titleLabel.trailingAnchor, bottom: titleLabel.bottomAnchor, trailing: nil)
        
        userLabel.anchor(top: titleLabel.bottomAnchor, leading: textView.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        userImageView.anchor(top: userLabel.topAnchor, leading: stackView.leadingAnchor, bottom: userLabel.bottomAnchor, trailing: stackView.trailingAnchor)
        
        textView.anchor(top: contentView.topAnchor,
                        leading: stackView.trailingAnchor,
                        bottom: contentView.bottomAnchor,
                        trailing: contentView.trailingAnchor,
                        padding: .init(top: 25, left: 0, bottom: 0, right: 0))
        
        stackView.anchor(top: textView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: textView.bottomAnchor,
                         trailing: nil,
                         padding: .init(top: 20, left: 30, bottom: 20, right: 0),size: CGSize(width: 30, height: 0))
        
        blueIcon.anchor(top: titleLabel.topAnchor, leading: nil, bottom: titleLabel.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 30, bottom: 0, right: 0))
        blueNumber.anchor(top: blueIcon.topAnchor, leading: blueIcon.trailingAnchor, bottom: blueIcon.bottomAnchor, trailing: nil)
        redIcon.anchor(top: titleLabel.topAnchor, leading: blueIcon.trailingAnchor, bottom: titleLabel.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 30, bottom: 0, right: 0))
        redNumber.anchor(top: redIcon.topAnchor, leading: redIcon.trailingAnchor, bottom: redIcon.bottomAnchor, trailing: nil)
        
        countLabel.anchor(top: titleLabel.topAnchor, leading: redNumber.trailingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 0, left: 30, bottom: 0, right: 20))
        
        initialUser()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(withTitle title: String, placeholder:String,tag:Int = 0) {
        titleLabel.text = title
        textView.text = placeholder
        textView.tag = tag
    }
    private func initialUser() {
        guard let user = DefaultsManager.shared.getCurrentUser() else {return}
        userLabel.text = user.name
        switch user.gender {
        case genderType.male.rawValue:
            userImageView.tintColor = .blueColor
        case genderType.female.rawValue:
            userImageView.tintColor = .redColor
//        case genderType.nonBinary.rawValue:
//            userImageView.tintColor = .mainColor
        default:
            break
        }
        updateIconNumbers()
    }
}

extension ParticipantsTableViewCell:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.ParticipantsTableViewCellTextViewDidChange(self, textView)
        
        guard let text = textView.text else {return}
        
        let names = text.split(separator: "\n")
        countLabel.text = "人數: \(String(names.count+1))"
        
        let lines = text.filter({ $0 == "\n"}).count
        while buttons.count > lines+1 {
            removeLastButtonFromArrayAndStack()
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let paragraph = textView.text {
            if text == "\n" && paragraph.filter({ $0 == "\n"}).count+1 > paragraph.split(separator: "\n").count {
                return false
            }
        }
        if text == "\n" {
            addButtonToArrayAndStackView()
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let text = textView.text, text.isEmpty || text.last == "\n"  {
            addButtonToArrayAndStackView()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text,
        let user = DefaultsManager.shared.getCurrentUser() else {return}
            if text.isEmpty || text.last == "\n" {
            if text.last == "\n"{
                textView.text.removeLast()
            }
            removeLastButtonFromArrayAndStack()
            
        }
        
        var participants:[String:Participant]  = [user.username:Participant(with: user)]
        
        var counter:Int = 1
        
        for (index,item) in text.split(separator: "\n").enumerated() {
            var gender:String
            
            switch buttons[index].tintColor! {
            case .blueColor:
                gender = genderType.male.rawValue
            case .redColor:
                gender = genderType.female.rawValue
            default:
                gender = genderType.male.rawValue
            }
            
            // check if key already exist, if yes rename it
            let name = String(item)
            if participants[name] != nil {
                let replacedName = name + "-" + String(counter)
                
                participants[replacedName] = Participant(name: replacedName, gender: gender, joinStatus: .going)
                counter += 1
            }else {
                participants[name] = Participant(name: name, gender: gender, joinStatus: .going)
            }
            
        }
        
        
        self.delegate?.ParticipantsTableViewCellTextViewDidEndEditing(self, textView, participants: participants)
    }
    
    private func addButtonToArrayAndStackView(_ user:User? = nil){
        var color = UIColor(named: "blueColor")
        if let gender = user?.gender {
            switch gender {
            case "male":
                color = UIColor(named: "blueColor")
            case "female":
                color = UIColor(named: "redColor")
            default:
                color = .mainColor
            }
        }
        
        let button:UIButton = {
            let view = UIButton()
            view.setImage(UIImage(systemName: "person.circle"), for: .normal)
            view.tintColor = color
            view.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            return view
        }()
        
        buttons.append(button)
        guard let lastButton = buttons.last else {return}
        stackView.addArrangedSubview(lastButton)
        updateIconNumbers()
    }
    
    private func removeLastButtonFromArrayAndStack(){
        if let lastButton = buttons.last {
            stackView.removeArrangedSubview(lastButton)
            buttons.removeLast().removeFromSuperview()
        }
        updateIconNumbers()
        self.delegate?.ParticipantsTableViewCellTextViewDidChange(self, textView)
    }
    
    @objc private func didTapButton(_ sender:UIButton){
        let isCurrentlyBlue = sender.tintColor == UIColor(named: "blueColor")
        sender.tintColor = isCurrentlyBlue ? UIColor(named: "redColor") : UIColor(named: "blueColor")
        updateIconNumbers()
        textViewDidEndEditing(textView)
        
    }
    
    private func updateIconNumbers(){
        
        var blueNumber = 0
        var redNumber = 0
        buttons.forEach({
            switch $0.tintColor! {
            case .blueColor:
                blueNumber += 1
            case .redColor:
                redNumber += 1
            default:
                break
            }
        })
        switch userImageView.tintColor! {
        case .blueColor:
            blueNumber += 1
        case .redColor:
            redNumber += 1
        default:
            break
        }
        
        self.blueNumber.text = String(blueNumber)
        self.redNumber.text = String(redNumber)


    }
    
}
