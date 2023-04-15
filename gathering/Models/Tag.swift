//
//  Tag.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-06.
//

import UIKit

enum TagType:Int, Codable {
    case newFriend
    case newImmigrant
    case interests
    case peoplCount
    case joined
    case grouping
    case grouped
}

struct Tag : Codable{
    let type:TagType
    var minMale:Int? = nil
    var minFemale:Int? = nil
    var minHeadcount:Int? = nil
    var genderSpecific:Bool? = nil
    
    var maleString:String {
        if let minMale = minMale, minMale > 0 {
            return "\(minMale)男"
        }else {
            return ""
        }
    }
    
    var femaleString:String {
        if let minFemale = minFemale, minFemale > 0 {
            return "\(minFemale)女"
        }else {
            return ""
        }
    }
    
    var headcountString:String {
        if let minHeadcount = minHeadcount, minHeadcount > 0 {
            return "\(minHeadcount)人"
        }else {
            return ""
        }
    }
    
    var tagString:String {
        switch type {
        case .newFriend:
            return "認識新朋友"
        case .newImmigrant:
            return "新移民交流"
        case .peoplCount:
            if genderSpecific ?? false {
                return "成團人數:\(maleString)\(femaleString)"
            } else {
                return "成團人數:\(headcountString)"
            }
        case .joined:
            return "已報名"
        case .interests:
            return "興趣交流"
        case .grouping:
            return  "組團中..."
        case .grouped:
            return "已成團"
        }
    }
    
    var color: UIColor {
        switch type {
        case .newFriend:
            return .lightMainColor
        case .newImmigrant:
            return .darkMainColor
        case .peoplCount:
            return .darkMainColor
        case .joined:
            return .tiffBlueColor
        case .interests:
            return .darkSecondaryColor
        case .grouping:
            return .darkMainColor
        case .grouped:
            return .darkSecondaryColor
        }
    }
    
    func getLabel(fontSize:CGFloat = 14) -> TagLabel {
        let tag = TagLabel()
        tag.eventTag = self
        tag.fontSize = fontSize
        return tag
    }
    
    
}



class TagLabel:UILabel {
    
    private let tagLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoMedium(ofSize: 14)
        return view
    }()
    
    private let backgroundView:UIView = {
        let view = UIView()
        return view
    }()
    
    var eventTag:Tag? {
        didSet{
            guard let eventTag = eventTag else {return}
            tagLabel.text = eventTag.tagString
            tagLabel.textColor = .white
            backgroundColor = eventTag.color
        }
    }
    var fontSize:CGFloat? {
        didSet {
            if let fontSize = fontSize {
                tagLabel.font = .robotoMedium(ofSize: fontSize)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tagLabel)
        
        layer.cornerRadius = 7
        layer.masksToBounds = true
        
        tagLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 5))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
