//
//  HomeSearchResultTableViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-17.
//

import UIKit


protocol HomeSearchResultTableViewControllerDelegate:AnyObject {
    func HomeSearchResultTableViewControllerDidChooseResult(_ view:HomeSearchResultTableViewController, result:HomeSearchResultType, searchText:String)
    
}

struct HomeSearchResult {
    static let defaultOptions:[HomeSearchResult] = [
        .init(homeResultType: .searchEvent, action: "搜尋活動:", text: "", description: "搜尋並參與其他人的活動。"),
        .init(homeResultType: .groupUp, action: "快速組團:", text: "", description: "設定目標人數，達到後便可成團"),
        .init(homeResultType: .searchPeople, action: "搜尋對", text: "有興趣的人", description: "尋找有相同喜好的人 "),
//        .init(homeResultType: .organiseEvent, action: "(Coming Soon) 建立活動:", text: "", description: "作為主辦人，舉辦活動讓其他人參加 "),
    ]
    
    let homeResultType:HomeSearchResultType
    let action:String
    let text:String
    let description:String
}

enum HomeSearchResultType {
    case organiseEvent
    case searchEvent
    case groupUp
    case searchPeople
}

class HomeSearchResultTableViewController: UIViewController {
    
    weak var  delegate:HomeSearchResultTableViewControllerDelegate?

    
    let tableView:UITableView = {
        let view = UITableView()
        return view
    }()
    
    private var task = DispatchWorkItem{}
    
    
    private var searchText:String = ""
    private var results:[HomeSearchResult] = HomeSearchResult.defaultOptions
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.alwaysBounceVertical = false
        tableView.frame = view.bounds
        tableView.backgroundColor = .systemBackground
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        
        tableView.dataSource = self
        tableView.register(HomeSearchResultTableViewCell.self, forCellReuseIdentifier: HomeSearchResultTableViewCell.identifier)
        
        
    }
    
    @objc private func didTapDismiss(){
    }
    
}

extension HomeSearchResultTableViewController:UITableViewDelegate,UITableViewDataSource {
    // MARK: - Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row != 1, indexPath.row != 3, searchText.count < 1 {
            AlertManager.shared.showAlert(title: "", message: "請輸入至少 2 個字進行搜尋。", from: self)
            return
        }
        
        
        let result = results[indexPath.row]
        delegate?.HomeSearchResultTableViewControllerDidChooseResult(self, result: result.homeResultType, searchText: searchText)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = results[indexPath.row]
        let cell = HomeSearchResultTableViewCell()
        cell.bindViewModel(viewModel: vm, searchText: searchText)
        return cell
    }
    
}


extension HomeSearchResultTableViewController:UISearchResultsUpdating {
    
    // MARK: - Update Search result
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text
        else { return }
        searchText = searchBarText
        tableView.reloadData()
    }
    
}


class HomeSearchResultTableViewCell:UITableViewCell {
    static let identifier = "HomeSearchResultTableViewCell"
    
    private let userLabel:UILabel = {
        let view = UILabel()
        view.textColor = .extraLightGray
        view.font = .systemFont(ofSize: 18)
        return view
    }()
    
    private let actionLabel:UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    private let descriptionLabel:UILabel = {
        let view = UILabel()
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: HomeSearchResultTableViewCell.identifier)
        [userLabel,actionLabel,descriptionLabel].forEach({contentView.addSubview($0)})
        
        actionLabel.anchor(top: contentView.topAnchor, leading: userLabel.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor,padding: .init(top: 10, left: 20, bottom: 0, right: 20))
        descriptionLabel.anchor(top: actionLabel.bottomAnchor, leading: actionLabel.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 10, right: 5))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bindViewModel(viewModel:HomeSearchResult, searchText:String) {
        let textString = "\(viewModel.action) '\(searchText)' \(viewModel.text)"
        actionLabel.text = textString
        descriptionLabel.text = viewModel.description
    }
}
