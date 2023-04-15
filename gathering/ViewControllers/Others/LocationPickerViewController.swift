//
//  LocationPickerViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-21.
//

import UIKit

class LocationPickerViewController: UIViewController {
    
    private let stackView:UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        return view
    }()
    
    private let titleLabel:UILabel = {
        
        let view = UILabel()
        view.text = "選擇你的地區:"
        view.textAlignment = .center
        view.font = .helveticaBold(ofSize: 20)
        return view
    }()

    var completion:(() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: stackView.leadingAnchor, bottom: stackView.topAnchor, trailing: stackView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 30, right: 0))
        
        let topPadding:CGFloat = view.height/3
        let leafPadding:CGFloat = 40
        
        let locations = LocationSwitch.allCases
        
        let height:CGFloat = CGFloat(44 * locations.count)
        
        stackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: topPadding, left: leafPadding, bottom: topPadding, right: leafPadding), size: .init(width: 0, height: height))
        
        
        for index in 0..<locations.count {
            let button = UIButton()
            button.setTitle(locations[index].rawValue, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            
        }
    }
    
    @objc private func didTapLocation(_ sender:UIButton){
        
        let locations = LocationSwitch.allCases
        
        UserDefaults.standard.set(locations[sender.tag].rawValue, forKey: UserDefaultsType.region.rawValue)
        
        DatabaseManager.shared.reset()
        
        completion?()
        
        self.dismiss(animated: true)
        
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct LOCATIONPreview: PreviewProvider {
    
    static var previews: some View {
        // view controller using programmatic UI
        LocationPickerViewController().toPreview()
    }
}
#endif

