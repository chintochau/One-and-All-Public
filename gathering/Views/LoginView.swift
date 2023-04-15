//
//  LoginView.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-13.
//

import UIKit

protocol LoginViewDelegate:AnyObject {
    func didTapLogin (_ view:LoginView,email:String,password:String)
    func didTapTerms()
    func didTapPrivacy()
}

class LoginView: UIView, UITextFieldDelegate {
    
    weak var delegate:LoginViewDelegate?
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    
    private let title:UILabel = {
        let view = UILabel()
        view.text = "歡迎回來"
        view.font = .systemFont(ofSize: 30, weight: .bold)
        view.numberOfLines = 2
        
        return view
    }()
    
    
    private let emailField:GATextField = {
        let view = GATextField()
        view.configure(name: "電郵地址")
        view.text = K.email
        view.autocapitalizationType = .none
        view.placeholder = "name@example.com"
        view.autocorrectionType = .no
        view.keyboardType = .emailAddress
        return view
    }()
    
    private let passwordField:GATextField = {
        let view = GATextField()
        view.configure(name: "密碼")
        view.text = K.password
        view.placeholder = "輸入密碼"
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        view.isSecureTextEntry = true
        return view
    }()
    
    
    let loginButton:UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("登入", for: .normal)
        view.backgroundColor = .mainColor
        view.layer.cornerRadius = 15
        view.tintColor = .white
        view.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return view
    }()
    
    let registerButton:UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("還沒有帳號？按此建立", for: .normal)
        view.tintColor = .link
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
    
    let indicator:UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    private let containView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(containView)
        
        [title,
         emailField,
         passwordField,
         loginButton,
         termsButton,
         privacyButton,
         registerButton,
         indicator
        ].forEach({
            containView.addSubview($0)
        })
        

        layoutConstraints()
        
        loginButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        gesture.numberOfTapsRequired = 1
        addGestureRecognizer(gesture)
    }
    
    
    private func layoutConstraints() {
        let padding: CGFloat = 20
        let space: CGFloat = 35
        let buttonHeight: CGFloat = 50
        
        
        // Set constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        containView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        containView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        // Title
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: containView.topAnchor, constant: padding).isActive = true
        title.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: padding).isActive = true
        title.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -padding).isActive = true

        // Email field
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 100).isActive = true
        emailField.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: padding).isActive = true
        emailField.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -padding).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Password field
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: space).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: padding).isActive = true
        passwordField.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -padding).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Register button
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: padding).isActive = true
        registerButton.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -padding).isActive = true

        // Login button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 30).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: padding+10).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -padding-10).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true

        // Indicator
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true

        // Privacy button
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30).isActive = true
        privacyButton.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: padding).isActive = true
        privacyButton.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -padding).isActive = true

        // Terms button
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.topAnchor.constraint(equalTo: privacyButton.bottomAnchor, constant: 10).isActive = true
        termsButton.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: padding).isActive = true
        termsButton.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -padding).isActive = true
        
        termsButton.bottomAnchor.constraint(equalTo: containView.bottomAnchor,constant:  0).isActive = true
        
    }

    
    @objc private func didTapView(){
        endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitle(text:String){
        title.text = text
    }
    

    
    @objc private func didTapSignIn(){
        endEditing(true)
        guard let email = emailField.text, let password = passwordField.text else {return}
        indicator.startAnimating()
        loginButton.isHidden = true
        delegate?.didTapLogin( self, email: email, password: password)
    }
    
    @objc private func didTapTermsButton(){
        endEditing(true)
        delegate?.didTapTerms()
    }
    
    @objc private func didTapPrivacy(){
        endEditing(true)
        delegate?.didTapPrivacy()
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.resignFirstResponder()
    }
    
    
}
