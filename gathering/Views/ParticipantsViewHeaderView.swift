//
//  ParticipantsViewHeaderView.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-29.
//

import UIKit

protocol ParticipantsViewHeaderViewDelegate:AnyObject {
    func didTapEnroll(_ view:ParticipantsViewHeaderView)
    func didTapQuit(_ view:ParticipantsViewHeaderView)
    func didTapEdit(_ view:ParticipantsViewHeaderView)
}

class ParticipantsViewHeaderView: UIView {
    
    weak var delegate:ParticipantsViewHeaderViewDelegate?
    
    
    // MARK: - Components
    private let participantsLabel:UILabel = {
        let view = UILabel()
        view.text = "參加者: "
        view.sizeToFit()
        return view
    }()
    private let headCountLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    private let maleCountLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    private let femaleCountLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let priceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 20,weight: .bold)
        view.sizeToFit()
        return view
    }()
    private let priceValueLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let enrollButton = GAButton(title: "報名")
    private let quitBUtton = GAButton(title: "退出")
    private let editButton = GAButton(title: "編輯")
    
    private let genderImageView:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .mainColor
        return view
    }()
    private let maleImageView:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .blueColor
        return view
    }()
    private let femaleImageView:UIImageView = {
        let view = UIImageView()
        view.image = .personIcon
        view.tintColor = .redColor
        return view
    }()
    
    
    // MARK: - Class members
    
    var viewModel:EventCellViewModel? {
        didSet{
            guard let viewModel = viewModel else {return}
            
            headCountLabel.text = viewModel.totalString
            maleCountLabel.text = viewModel.maleString
            femaleCountLabel.text = viewModel.femaleString
             
            
            print(viewModel)
            print("isOrganiser: \(viewModel.isOrganiser)")
            print("isJoined: \(viewModel.isJoined)")
            
            isOrganiser = viewModel.isOrganiser
            isJoined = viewModel.isJoined
            
        }
    }
    
    var isOrganiser:Bool = false {
        didSet {
            quitBUtton.isHidden = isOrganiser
            enrollButton.isHidden = isOrganiser
            editButton.isHidden = !isOrganiser
        }
    }
    
    var isJoined:Bool = false {
        didSet{
            if isOrganiser { return }
            enrollButton.isHidden = isJoined
            quitBUtton.isHidden = !isJoined
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [
            participantsLabel,
            priceTitleLabel,
            priceValueLabel,
            enrollButton,
            headCountLabel,
            quitBUtton,
            editButton,
            maleImageView,
            femaleImageView,
            genderImageView,
            maleCountLabel,
            femaleCountLabel
        ].forEach({addSubview($0)})
        backgroundColor = .systemBackground.withAlphaComponent(0.4)
        enrollButton.addTarget(self, action: #selector(didTapEnroll), for: .touchUpInside)
        quitBUtton.addTarget(self, action: #selector(didTapQuit), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        
        layer.cornerRadius = 10
        layer.borderColor = UIColor.opaqueSeparator.cgColor
        layer.borderWidth = 0.5
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding:CGFloat = 30
        priceTitleLabel.frame = CGRect(x: padding, y: 20, width: priceTitleLabel.width, height: priceTitleLabel.height)
        
        let buttonWidth:CGFloat = (width-40)/2
        let buttonheight:CGFloat = 40
        enrollButton.frame = CGRect(x: width-padding-buttonWidth, y: (height-buttonheight)/2-10, width: buttonWidth, height: buttonheight)
        quitBUtton.frame = CGRect(x: width-padding-buttonWidth, y: (height-buttonheight)/2-10, width: buttonWidth, height: buttonheight)
        editButton.frame = CGRect(x: width-padding-buttonWidth, y: (height-buttonheight)/2-10, width: buttonWidth, height: buttonheight)
        
        
        participantsLabel.sizeToFit()
        participantsLabel.frame = CGRect(x: padding, y: top+10, width: participantsLabel.width, height: participantsLabel.height)
        
        
        let imageSize:CGFloat = 25
        genderImageView.frame = CGRect(x: participantsLabel.left, y: participantsLabel.bottom+5, width: imageSize, height: imageSize)
        genderImageView.isHidden = true
        headCountLabel.sizeToFit()
        headCountLabel.frame = CGRect(x: participantsLabel.right+5, y: participantsLabel.top, width: width-participantsLabel.width-padding, height: headCountLabel.height)
        
        
        maleImageView.frame  = CGRect(x: participantsLabel.left, y: participantsLabel.bottom+5, width: imageSize, height: imageSize)
        femaleImageView.frame  = CGRect(x: participantsLabel.left, y: maleImageView.bottom, width: imageSize, height: imageSize)
        
        
        maleCountLabel.sizeToFit()
        maleCountLabel.frame = CGRect(x: maleImageView.right+5, y: maleImageView.top, width: maleCountLabel.width, height: maleImageView.height)
        
        femaleCountLabel.sizeToFit()
        femaleCountLabel.frame = CGRect(x: femaleImageView.right+5, y: femaleImageView.top, width: femaleCountLabel.width, height: femaleCountLabel.height)
        
        
        
    }
    @objc private func didTapEnroll(){
        delegate?.didTapEnroll(self)
    }
    
    @objc private func didTapQuit(){
        delegate?.didTapQuit(self)
    }
    
    @objc private func didTapEdit(){
        delegate?.didTapEdit(self)
    }
    
}
