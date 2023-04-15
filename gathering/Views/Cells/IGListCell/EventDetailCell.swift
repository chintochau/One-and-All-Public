//
//  EventDetailCell.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-27.
//

import IGListKit
import UIKit

class EventDetailInfoCell : UICollectionViewCell, ListBindable {
    
    static let identifier = "EventDetailInfoCell"
    
    private let dateLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        view.numberOfLines = 2
        return view
    }()
    private let timeLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        return view
    }()
    private let locationLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        view.numberOfLines = 4
        view.lineBreakMode = .byClipping
        return view
    }()
    private let detailTextView:UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .robotoRegularFont(ofSize: 16)
        view.isScrollEnabled = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 5
        view.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return view
    }()
    
    private let mapButton:UIButton = {
        let view = UIButton(type: .system)
        view.setTitleColor(.link, for: .normal)
        view.setTitle("地圖", for: .normal)
        view.titleLabel?.font = .robotoRegularFont(ofSize: 14)
        view.isHidden = true
        return view
    }()
    
    private let separatorView:UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    private let upperSeparatorView:UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    var location:Location?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [upperSeparatorView,dateLabel,timeLabel,locationLabel,detailTextView,separatorView,mapButton].forEach({addSubview($0)})
        
        let padding:CGFloat = 30
        detailTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 10, left: padding, bottom: padding, right: padding))
        detailTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        
        let labelPadding:CGFloat = 10
        
        upperSeparatorView.anchor(top: detailTextView.bottomAnchor, leading: detailTextView.leadingAnchor, bottom: nil, trailing: detailTextView.trailingAnchor, padding: .init(top: labelPadding, left: 0, bottom: labelPadding, right: 0),size: .init(width: 0, height: 3))
        
        
        dateLabel.anchor(top: upperSeparatorView.bottomAnchor, leading: detailTextView.leadingAnchor, bottom: nil, trailing: detailTextView.trailingAnchor,
                         padding: .init(top: labelPadding, left: 0, bottom: labelPadding, right: 0))
        
        locationLabel.anchor(top: dateLabel.bottomAnchor, leading: dateLabel.leadingAnchor, bottom: nil, trailing:nil,
                             padding: .init(top: labelPadding, left: 0, bottom: labelPadding, right: 0))
        locationLabel.trailingAnchor.constraint(lessThanOrEqualTo: mapButton.leadingAnchor, constant: 0).isActive = true
        
        separatorView.anchor(top: locationLabel.bottomAnchor, leading: dateLabel.leadingAnchor, bottom: bottomAnchor, trailing: detailTextView.trailingAnchor,
                             padding: .init(top: 10, left: 0, bottom: 0, right: 0),
                             size: .init(width: 0, height: 3))
        
        mapButton.anchor(top: locationLabel.topAnchor, leading: nil, bottom: locationLabel.bottomAnchor, trailing: detailTextView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 0),size: .init(width: 40, height: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? EventDetailsViewModel else {return}
        
        dateLabel.attributedText = createAttributedText(with: vm.dateString, image: .dateIcon)
        timeLabel.attributedText = createAttributedText(with: vm.timeString, image: .timeIcon)
        locationLabel.attributedText = createAttributedText(with: vm.locationString, image: .locationIcon)
        
        // Create an attributed string with the same text as the text view
        let attributedString = NSMutableAttributedString(string: vm.intro ?? "",attributes: [
            NSAttributedString.Key.font: UIFont.robotoRegularFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.label
        ])

        // Detect any URLs in the attributed string and add a link attribute to them
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))

        for match in matches {
            guard let url = match.url else { continue }
            attributedString.addAttribute(.link, value: url, range: match.range)
        }
        
        // Set the attributed string as the text view's attributed text
        detailTextView.attributedText = attributedString
        // Set the data detector types of the text view to .link to make the links clickable
        detailTextView.dataDetectorTypes = .link
        
        mapButton.addTarget(self, action: #selector(openGoogleMap), for: .touchUpInside)
        
        location = vm.location
        
        if location?.latitude != nil, location?.longitude != nil {
            mapButton.isHidden = false
        }
    }
    
    @objc private func openGoogleMap(){
        guard let long = location?.longitude,
              let lat = location?.latitude,
              let name = location?.name else {return}
        
        var locationName = name.replacingOccurrences(of: " ", with: "+")
        
        if let address = location?.address {
            locationName += "+\(address)".replacingOccurrences(of: " ", with: "+")
        }
        
        let encodedString = locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        // Construct the Google Maps URL with the latitude and longitude as parameters
        if let  url = URL(string: "comgooglemaps://?center=\(lat),\(long)&zoom=20&q=\(encodedString)&views=map") {
            
            // Open the Google Maps URL
            UIApplication.shared.open(url)
        }

    }
    
}



class EventDetailParticipantsCell : UICollectionViewCell, ListBindable {
    
    private let confirmedParticipantsLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        return view
    }()
    
    private let signedUpParticipantsLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        return view
    }()
    
    
    private let genderTextLabel:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 16)
        return view
    }()
    
    
    private let femaleBox:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 4
        view.backgroundColor = .systemBackground
        return view
    }()
    private let maleBox:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 4
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let femaleIconView:UIImageView = {
        let view = UIImageView()
        view.image = .femaleIcon
        view.contentMode  = .scaleAspectFit
        return view
    }()
    private let maleIconView:UIImageView = {
        let view = UIImageView()
        view.image = .maleIcon
        view.contentMode  = .scaleAspectFit
        return view
    }()
    private let femaleNumber:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 20)
        return view
    }()
    private let maleNumber:UILabel = {
        let view = UILabel()
        view.font = .robotoRegularFont(ofSize: 20)
        return view
    }()
    
    
    private let separatorView:UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private let tagLabel:TagLabel = {
        let view = TagLabel()
        view.fontSize = 16
        return view
    }()
    
    static let identifier = "EventDetailParticipantsCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [confirmedParticipantsLabel,signedUpParticipantsLabel,genderTextLabel,femaleBox,maleBox,separatorView,tagLabel].forEach({addSubview($0)})
        
        tagLabel.anchor(top: topAnchor, leading: signedUpParticipantsLabel.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        signedUpParticipantsLabel.anchor(top: tagLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 5, left: 30, bottom: 20, right: 30))
        
        confirmedParticipantsLabel.anchor(top: signedUpParticipantsLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,
                                padding: .init(top: 5, left: 30, bottom: 20, right: 30))
        genderTextLabel.anchor(top: confirmedParticipantsLabel.bottomAnchor, leading: confirmedParticipantsLabel.leadingAnchor, bottom: nil, trailing: confirmedParticipantsLabel.trailingAnchor,
                               padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        let boxWidth:CGFloat = (width-90)/2
        femaleBox.anchor(top: genderTextLabel.bottomAnchor, leading: genderTextLabel.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 0, bottom: 20, right: 0),size: .init(width: boxWidth, height: 50))
        maleBox.anchor(top: femaleBox.topAnchor, leading: nil, bottom: nil, trailing: confirmedParticipantsLabel.trailingAnchor,size: .init(width: boxWidth, height: 50))
        
        separatorView.anchor(top: femaleBox.bottomAnchor, leading: genderTextLabel.leadingAnchor, bottom: bottomAnchor, trailing: maleBox.trailingAnchor,
                             padding: .init(top: 30, left: 0, bottom: 0, right: 0),size: .init(width: 0, height: 3))
        
        
        femaleBox.addSubview(femaleIconView)
        femaleBox.addSubview(femaleNumber)
        maleBox.addSubview(maleIconView)
        maleBox.addSubview(maleNumber)
        
        let iconSize:CGFloat = 27
        let padding:CGFloat = (50 - iconSize)/2
        femaleIconView.anchor(top: femaleBox.topAnchor, leading: femaleBox.leadingAnchor, bottom: nil, trailing: nil,
                              padding: .init(top: padding, left: padding, bottom: 0, right: 0),
                              size: .init(width: iconSize, height: iconSize))
        maleIconView.anchor(top: maleBox.topAnchor, leading: maleBox.leadingAnchor, bottom: nil, trailing: nil,
                            padding: .init(top: padding, left: padding, bottom: 0, right: 0),
                            size: .init(width: iconSize, height: iconSize))
        femaleNumber.anchor(top: femaleIconView.topAnchor, leading: femaleIconView.trailingAnchor, bottom: femaleIconView.bottomAnchor, trailing: nil,
                            padding: .init(top: 0, left: 20, bottom: 0, right: 0))
        
        maleNumber.anchor(top: maleIconView.topAnchor, leading: maleIconView.trailingAnchor, bottom: maleIconView.bottomAnchor, trailing: nil,
                          padding: .init(top: 0, left: 20, bottom: 0, right: 0))
        
  
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? EventParticipantsViewModel else {return}
        
//        let attributedText = NSMutableAttributedString(string: "")
//        let text:NSAttributedString = createAttributedText(with: "已報名人數： ", image: .participantsIcon )
//        let number:NSAttributedString = NSAttributedString(
//            string: vm.numberOfParticipants
////            ,attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
//        )
//
//        attributedText.append(text)
//        attributedText.append(number)
//
//        signedUpParticipantsLabel.attributedText = attributedText
        signedUpParticipantsLabel.text = "報名人數: \(vm.signedUpParticipants.count)"
        
        confirmedParticipantsLabel.text = "確認人數: \(vm.numberOfParticipants)"
        
        genderTextLabel.text = "確認參與者性別分佈: "
        femaleNumber.text = vm.numberOfFemale
        maleNumber.text = vm.numberOfMale
        tagLabel.eventTag = vm.tag
    }
    
    
    
}
