//
//  ProfileViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import UIKit
import FirebaseAuth
import SafariServices

class ProfileViewController: UIViewController {
    
    private let logoutButton = GAButton(title: "Logout")
    
    private let tableView:UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.backgroundColor = .systemBackground
        view.contentInset = .init(top: 0, left: 0, bottom: 30, right: 0)
        view.register(ValueTableViewCell.self, forCellReuseIdentifier: ValueTableViewCell.identifier)
        return view
    }()
    
    private var viewModels = [[InputFieldType]]()
    private var headerViewModel:ProfileHeaderViewViewModel?
    private let loginView = LoginView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        
        
        // Add app version label
        let appVersionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        appVersionLabel.textAlignment = .center
        appVersionLabel.textColor = .gray
        appVersionLabel.font = .systemFont(ofSize: 14)
        appVersionLabel.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
        tableView.tableFooterView = appVersionLabel
        
        
        
        if UserDefaults.standard.string(forKey: "username") == nil && AuthManager.shared.isSignedIn{
            AuthManager.shared.signOut { success in
                print("Signed out")
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AuthManager.shared.isSignedIn {
            configureViewModels()
            configureProfileView()
        }else {
            configureLoginView()
        }
    }
    
    private func configureViewModels(){
        
        guard let user = DefaultsManager.shared.getCurrentUser() else {
            AuthManager.shared.signOut()
            return
        }
        
        headerViewModel = .init(user:user)
        
        viewModels = [
            // events
            [],
            // setting
            [.value(title: "地區", value: UserDefaults.standard.string(forKey: UserDefaultsType.region.rawValue) ?? "Toronto"),
             .value(title: "語言", value: "中文")],
            // support
            [.value(title: "建議", value: "")],
            // about
            [.value(title: "隱私政策", value: ""),
             .value(title: "服務條款", value: ""),
             .value(title: "Cookie 政策", value: "")],
            // profile
            [.value(title: "編輯個人檔案", value: ""),
             .value(title: "刪除帳號", value: "")
            ]
        ]
        tableView.reloadData()
        
    }
    
    private func configureProfileView() {
        view.addSubview(tableView)
        
        tableView.fillSuperview()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
    }
    private func configureLoginView() {
        navigationItem.title = "登入"
        navigationItem.rightBarButtonItem = nil
        view.addSubview(loginView)
        loginView.delegate = self
        loginView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if AuthManager.shared.isSignedIn {
            layoutProfileView()
        }else {
            loginView.frame = view.safeAreaLayoutGuide.layoutFrame
        }
    }
    private func layoutProfileView(){
        navigationItem.title = "個人檔案"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "編輯", style: .plain, target: self, action: #selector(didTapEditProfile))
        self.loginView.removeFromSuperview()
    }
    
    @objc private func didTapEditProfile(fullScreen:Bool = false){
        
        guard let user = DefaultsManager.shared.getCurrentUser() else {return}
        
        let vc = EditProfileViewController(user: user)
        
        
        vc.completion = { [weak self] in
            self?.configureViewModels()
            self?.tableView.reloadData()
        }
        let navVc = UINavigationController(rootViewController: vc)
        
        if fullScreen {
            
            navVc.modalPresentationStyle = .fullScreen
        }
        present(navVc, animated: true)
    }
    
    @objc private func didTapLogOut(){
        
        AuthManager.shared.signOut { bool in
            DefaultsManager.shared.resetUserProfile()
            self.tableView.removeFromSuperview()
            self.configureLoginView()
        }
    }
    
    // MARK: - Tap Register
    @objc private func didTapRegister(){
        
        loginView.endEditing(true)
        
        let vc = RegisterViewController()
        vc.completion = {[weak self] in
            self?.configureViewModels()
            self?.configureProfileView()
            self?.didTapEditProfile(fullScreen: true)
        }
        
        present(UINavigationController(rootViewController: vc),animated: true)
    }
    
}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource {
    // MARK: - Section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    
    // MARK: - Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModels[indexPath.section][indexPath.row] {
        case .value(title: let title, value: let value) :
            let cell = tableView.dequeueReusableCell(withIdentifier: ValueTableViewCell.identifier, for: indexPath) as! ValueTableViewCell
            cell.configure(withTitle: title, value: value,index: indexPath.row)
            return cell
        default: return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? ValueTableViewCell {
            switch indexPath.section{
            case 0:
                break
            case 1:
                switch cell.index {
                case 0:
                    let vc = LocationPickerViewController()
                    vc.completion = {
                        self.configureViewModels()
                    }
                    present(vc, animated: true)
                case 1:
                    break
                default:
                    break
                }
            case 2:
                if let url = URL(string: "https://docs.google.com/forms/d/1w_Wj_iPpnmJ7lbSuUKisMJbPvkGAZnpeTzQ21Msv8W4/edit?pli=1") {
                    UIApplication.shared.open(url)
                }
            case 3:
                switch cell.index {
                case 0:
                    self.didTapPrivacy()
                case 1:
                    self.didTapTerms()
                case 2:
                    self.didTapCookie()
                default:
                    break
                }
            case 4:
                switch cell.index {
                case 0:
                    didTapEditProfile()
                case 1:
                    AlertManager.shared.showTextInputAlert(title: "", message: "您確定要永久刪除帳戶嗎？此操作無法撤消，並且所有資料將會被刪除。如果確定，請輸入您的密碼，並點擊'確認'以繼續。否則，請點擊'取消'返回您的帳戶設定。", placeholder: "密碼", buttonMessage: "確定刪除" , isDestructive: true) { [weak self] password, isConfirmTapped in

                        if isConfirmTapped {
                            guard let view = self?.view, let password = password, let self = self else {return}
                            
                            LoadingIndicator.shared.showLoadingIndicator(on: view)
                            
                            AuthManager.shared.deleteAccount(password: password) { success in
                                LoadingIndicator.shared.hideLoadingIndicator()
                                if success {
                                    AuthManager.shared.signOut { success in
                                        AlertManager.shared.showAlert(title: "", message: "帳號已刪除", from: self) { success in
                                            self.viewWillAppear(true)
                                        }
                                    }
                                }else {
                                    AlertManager.shared.showAlert(title: "", message: "請輸入正確密碼",from: self)
                                }
                            }
                        }
                    }
                default:
                    break
                }
            default:
                print("Not implemented yet")
            }
        }
        
    }
    
    // MARK: - Header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            guard let headerViewModel = headerViewModel else {return nil}
            let headerView = ProfileHeaderView()
            headerView.configure(with: headerViewModel)
            return headerView
        case 1:
            let view = SectionHeaderView()
            view.configure(with: "一般設定")
            return view
        case 2:
            let view = SectionHeaderView()
            view.configure(with: "支援")
            return view
        case 3:
            let view = SectionHeaderView()
            view.configure(with: "關於")
            return view
        case 4:
            let view = SectionHeaderView()
            view.configure(with: "個人檔案")
            return view
            
        default: return nil
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 200
        }
        return 40
        
    }
    
    
    // MARK: - Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard section == viewModels.count - 1 else { return nil }
        let footerView = UIView()
        footerView.addSubview(logoutButton)
        logoutButton.anchor(
            top: footerView.topAnchor,
            leading: footerView.leadingAnchor,
            bottom: footerView.bottomAnchor,
            trailing: footerView.trailingAnchor,
            padding: .init(top: 20, left: 20, bottom: 20, right: 20))
        logoutButton.addTarget(self, action: #selector(didTapLogOut), for: .touchUpInside)
        return footerView
    }
    
    
}

extension ProfileViewController:LoginViewDelegate {
    
    func didTapPrivacy() {
        let vc = PolicyViewController(title: "隱私政策", policyString: Policy.privacyPolicy)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    func didTapTerms() {
        let vc = PolicyViewController(title: "服務條款", policyString: Policy.terms)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    func didTapCookie() {
        let vc = PolicyViewController(title: "Cookie 政策", policyString: Policy.cookiePolicy)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    
    
    // MARK: - didTapLogin
    
    func didTapLogin(_ view: LoginView, email: String, password: String) {
        
        AuthManager.shared.logIn(email: email, password: password) { [weak self] user in
            
            view.indicator.stopAnimating()
            view.loginButton.isHidden = false
            
            guard let self = self else {return}
            
            guard user != nil else {
                AlertManager.shared.showAlert(title: "", message: "登入失敗，請檢查您的電郵及密碼是否正確。", from: self)
                
                return
            }
            self.configureViewModels()
            self.loginView.removeFromSuperview()
            self.configureProfileView()
            
            CustomNotificationManager.shared.requestForNotification()
            
        }
        
    }
    
    
}

