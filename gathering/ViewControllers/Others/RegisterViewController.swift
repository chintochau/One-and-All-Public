//
//  RegisterViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-15.
//

import UIKit

class RegisterViewController: UIViewController {
    
    var completion: (() -> Void)?
    
    
    private let scrollView:UIScrollView = {
        let view = UIScrollView()
        view.keyboardDismissMode = .interactive
        view.alwaysBounceVertical = true
        return view
    }()
    
    private let contentView:UIView = {
        let view = UIView()
        
        return view
        
    }()
    
    
    private let titleLabel:UILabel = {
        let view = UILabel()
        view.text = "創建新帳戶"
        view.font = .systemFont(ofSize: 30, weight: .bold)
        return view
    }()
    
    private let usernameField: GATextField = {
        let view = GATextField()
        view.configure(name: "用戶名")
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.text = K.username
        view.placeholder = "輸入您的用戶名"
        view.keyboardType = .asciiCapable
        view.textContentType = .username
        return view
    }()
    
    private let emailField:GATextField = {
        let view = GATextField()
        view.configure(name: "電郵地址")
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.text = K.email
        view.placeholder = "name@example.com"
        view.keyboardType = .emailAddress
        return view
    }()
    
    private let passwordField:GATextField = {
        let view = GATextField()
        view.configure(name: "密碼")
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.text = K.password
        view.placeholder = "輸入您的密碼"
        view.isSecureTextEntry = true
        return view
    }()
    
    private let confirmPasswordField:GATextField = {
        let view = GATextField()
        view.configure(name: "確認密碼")
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.text = K.password
        view.placeholder = "重複輸入密碼"
        view.isSecureTextEntry = true
        return view
    }()
    
    
    private let agreeText:UILabel = {
        let view = UILabel()
        view.text = Policy.agreedMessage
        view.numberOfLines = 2
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    private let signUpButton:UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("註冊", for: .normal)
        view.backgroundColor = .mainColor
        view.layer.cornerRadius = 15
        view.tintColor = .white
        view.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return view
    }()
    
    private let termsButton:UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("服務條款", for: .normal)
        view.tintColor = .link
        return view
    }()
    
    private let privacyButton:UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("隱私政策", for: .normal)
        view.tintColor = .link
        return view
    }()
    
    private let indicator:UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "註冊"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector( didTapClose))
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel,
         usernameField,
         emailField,
         passwordField,
         confirmPasswordField,
         signUpButton,
         termsButton,
         privacyButton,
         indicator,
         agreeText
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
            
        })
        
        
        setupConstrants()
        addTapCancelGesture()
        
        
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        
        
        usernameField.delegate = self
    }
    
    
    private func setupConstrants(){
        
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            usernameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            usernameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            usernameField.heightAnchor.constraint(equalToConstant: 50),
            
            emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 35),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 35),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 35),
            confirmPasswordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),
            
            termsButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 15),
            termsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            termsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            privacyButton.topAnchor.constraint(equalTo: termsButton.bottomAnchor, constant: 0),
            privacyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            privacyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            agreeText.topAnchor.constraint(equalTo: privacyButton.bottomAnchor, constant: 20),
            agreeText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            agreeText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            signUpButton.topAnchor.constraint(equalTo: agreeText.bottomAnchor, constant:10),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            indicator.topAnchor.constraint(equalTo: signUpButton.topAnchor),
            indicator.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor),
            indicator.bottomAnchor.constraint(equalTo: signUpButton.bottomAnchor)
            
        ])
        
    }
    
    
    private func addTapCancelGesture(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapCancel))
        gesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(gesture)
    }
    
    
    
    @objc private func didTapPrivacy() {
        let vc = PolicyViewController(title: "隱私政策", policyString: Policy.privacyPolicy)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    @objc private func didTapTerms() {
        let vc = PolicyViewController(title: "服務條款", policyString: Policy.terms)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    
    @objc private func didTapCancel(){
        view.endEditing(true)
    }
    
    @objc private func didTapClose(){
        dismiss(animated: true)
    }
    
    @objc private func didTapSignUp(){
        guard let email = emailField.text, !email.isEmpty,
              email.isValidEmail(),
              let password = passwordField.text, !password.isEmpty,
              password.count >= 8,
              let confirmPassword = confirmPasswordField.text, confirmPassword == password,
              let username = usernameField.text, !username.isEmpty, username.count>=5
        else {
            // Show an alert indicating invalid input
            let alert = UIAlertController(title: "輸入無效", message: "請輸入有效的電子郵件，至少8個字的密碼，並確保密碼匹配。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
            
            return
        }
        
        indicator.startAnimating()
        indicator.isHidden = false
        signUpButton.isHidden = true
        
        AuthManager.shared.signUp(username: username, email: email, password: password) {[weak self] user in
            guard let user  = user else {
                
                let alert = UIAlertController(title: "帳戶已存在", message: "此電郵地址已被註冊。請使用不同的電郵地址或登入現有帳戶。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .cancel))
                self?.present(alert, animated: true)
                
                self?.indicator.isHidden = true
                self?.signUpButton.isHidden = false
                return
            }
            
            DefaultsManager.shared.updateUserProfile(with: user)
            self?.dismiss(animated: false)
            self?.completion?()
            CustomNotificationManager.shared.requestForNotification()
        }
    }
}



extension RegisterViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            let filteredText = text.filter({ $0.isLetter || $0.isNumber }).lowercased()
            textField.text = filteredText
        }
    }

    
}
