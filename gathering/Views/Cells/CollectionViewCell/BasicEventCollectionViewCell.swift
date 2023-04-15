//
//  EventSmallCollectionViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import UIKit
import SDWebImage
import IGListKit

class BasicEventCollectionViewCell: UICollectionViewCell,ListBindable {
    
    
    static let titleTextSize:CGFloat = 20
    static let subTextSize:CGFloat = 12
    static let introTextSize:CGFloat = 0
    static let iconSize:CGFloat = 20
    static let generalIconSize:CGFloat = 40
    
    let profileImageview:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .lightGray
        view.layer.masksToBounds = true
        return view
    }()
    
    let moreButton:UIButton = {
        let view = UIButton(type: .system)
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = .label
        return view
    }()
    
    let profileTitleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .robotoRegularFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let eventImageView:UIImageView = {
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    let emojiIconLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: generalIconSize)
        return view
    }()
    
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = .robotoSemiBoldFont(ofSize: 24)
        label.numberOfLines = 2
        return label
    }()
    
    let introLabel:UILabel = {
        let view = UILabel()
        view.numberOfLines = 3
        view.lineBreakMode = .byTruncatingTail
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()
    
    let dateLabel:UILabel = {
        let label = UILabel()
        label.font = .robotoRegularFont(ofSize: 14)
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    let locationLabel:UILabel = {
        let label = UILabel()
        label.font = .robotoRegularFont(ofSize: 14)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    let headCountLabel:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: subTextSize)
        view.numberOfLines = 2
        view.textColor = .secondaryLabel
        view.textAlignment = .right
        return view
    }()
    
    
    let likeButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName:  "heart"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    let shareButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    let maleIconImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = .maleIcon
        return view
    }()
    
    let femaleIconImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = .femaleIcon
        return view
    }()
    
    
    let totalIconImageView:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName:  "person.crop.circle")
        view.contentMode = .scaleAspectFit
        view.tintColor = .mainColor
        view.isHidden = true
        return view
    }()
    
    let maleNumber:UILabel = {
        let view = UILabel()
        return view
    }()
    
    let femaleNumber:UILabel = {
        let view = UILabel()
        return view
    }()
    
    let totalNumber:UILabel = {
        let view = UILabel()
        view.textAlignment = .right
        return view
    }()
    
    let priceLabel:UILabel = {
        let view = UILabel()
        
        return view
    }()
    
    
     let backgroundShade:UIView = {
        let view = UIView()
        view.backgroundColor = .streamWhiteSnow
        return view
    }()
    
    
    let gradientLayer:CAGradientLayer = {
        let view = CAGradientLayer()
        view.colors = [UIColor.mainColor.withAlphaComponent(0.5).cgColor, UIColor.darkMainColor.withAlphaComponent(0.5).cgColor]
        view.locations = [0.0, 1.0]
        return view
    }()
    
    let imageDefaultText:UILabel = {
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 2
        textLabel.font = .righteousFont(ofSize: 50)
//        textLabel.text = "Ca-\nTher"
        textLabel.textColor = .secondaryTextColor.withAlphaComponent(0.7)
        textLabel.textAlignment = .center
        return textLabel
    }()
    
    let friendsNumber:UILabel = {
        let view = UILabel()
        view.textColor = .lightGray
        view.font = .robotoRegularFont(ofSize: 12)
        return view
    }()
    
    
    private var postID:String?
    private var referencePath:String?
    private var username:String?
    var viewController:UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [
            backgroundShade,
            profileImageview,
            eventImageView,
            titleLabel,
            likeButton,
            shareButton,
            maleIconImageView,
            femaleIconImageView,
            maleNumber,
            femaleNumber,
            totalIconImageView,
            totalNumber,
            priceLabel,
            emojiIconLabel,
            introLabel,
            profileTitleLabel,
            dateLabel,
            locationLabel,
            friendsNumber,
            moreButton
        ].forEach({addSubview($0)})
        
        
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.sizeToFit()
        titleLabel.sizeToFit()
        locationLabel.sizeToFit()
        
        gradientLayer.frame = eventImageView.bounds
        imageDefaultText.frame = eventImageView.bounds
//        imageDefaultText.center = eventImageView.center
        eventImageView.layer.addSublayer(gradientLayer)
        eventImageView.addSubview(imageDefaultText)
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageview.image = .personIcon
        eventImageView.image = nil
        dateLabel.text = nil
        titleLabel.text = nil
        locationLabel.text = nil
        likeButton.setImage(UIImage(systemName:  "heart"), for: .normal)
        likeButton.tintColor = .label
        emojiIconLabel.text = nil
        introLabel.text = nil
        profileTitleLabel.text = nil
        maleNumber.textColor = .label
        femaleNumber.textColor = .label
        totalNumber.text = nil
        totalNumber.textColor = .label
        
        [
            totalNumber,totalIconImageView,maleIconImageView,maleNumber,femaleNumber,femaleIconImageView
        ].forEach({$0.isHidden = false})
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? EventCellViewModel else {return}
        
        username = vm.organiser?.username ?? ""
        postID = vm.id
        referencePath = vm.event.referencePath
        
        
        if let profileImage = vm.organiser?.profileUrlString {
            profileImageview.sd_setImage(with: URL(string: profileImage))
        }
        eventImageView.sd_setImage(with: URL(string: vm.imageUrlString ?? "")) { [weak self] image, _, _, _ in
            self?.gradientLayer.isHidden = image != nil
            self?.imageDefaultText.isHidden = image != nil
        }
        
        
        friendsNumber.text = vm.numberOfFriends > 0 ? "你有 \(vm.numberOfFriends) 個朋友參加左" : ""
        
        
        dateLabel.text = vm.dateString
        locationLabel.attributedText = createAttributedText(with: vm.location, image: .locationIcon)
        
        
        
        let usernameText = NSMutableAttributedString(string: vm.organiser?.name ?? "",attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        profileTitleLabel.attributedText = usernameText
        
        titleLabel.text = vm.title
        
        imageDefaultText.text = vm.emojiString
        
        introLabel.text = vm.intro
        
        if !vm.headcount.isGenderSpecific {
            totalNumber.text = vm.totalString
            totalNumber.isHidden = false
        }
        
        maleNumber.text = vm.maleString
        femaleNumber.text = vm.femaleString 
        
        if vm.event.headCountString().isMaleFull {
            maleNumber.textColor = .darkGray
        }
        if vm.event.headCountString().isFemaleFull {
            femaleNumber.textColor = .darkGray
        }
        if vm.event.headCountString().isFull {
            totalNumber.textColor = .darkGray
        }
        
        
        
    }
    
    @objc private func didTapLike (){
        print("LIKE")
    }
    
    @objc private func didTapReport(){
        guard let postID = postID, let referencePath = referencePath, let username  = username, let vc = viewController else {return}
        AlertManager.shared.reportPost(username: username,eventID: postID, referencePath: referencePath, viewController: vc)
    }
    
}
