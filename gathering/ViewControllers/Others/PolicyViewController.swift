//
//  PolicyViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-12.
//

import UIKit

class PolicyViewController: UIViewController {
    
    let policyString:String
    
    private let policyTextView:UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    
    init(title:String,policyString: String) {
        self.policyString = policyString
        policyTextView.text = policyString
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = title
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(policyTextView)
        policyTextView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                              padding: .init(top: 10, left: 10, bottom: 10, right: 10)
        )
        
        policyTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        
        

    }
    

}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct Preview: PreviewProvider {
    
    static var previews: some View {
        // view controller using programmatic UI
        PolicyViewController(title: "Privacy Policy", policyString: Policy.privacyPolicy).toPreview()
    }
}
#endif

