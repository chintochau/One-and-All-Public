//
//  GeneralSearchResultViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-09.
//

import UIKit

protocol GeneralSearchResultViewControllerDelegate:AnyObject {
    func GeneralSearchResultViewControllerDelegateDidChooseResult(_ view:GeneralSearchResultViewController, result:User)
    
}

class GeneralSearchResultViewController: UIViewController {
    
    weak var  delegate:GeneralSearchResultViewControllerDelegate?
    
    let tableView:UITableView = {
        let view = UITableView()
        return view
    }()
    
    private var task = DispatchWorkItem{}
    
    private var results = [User]()
    
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension GeneralSearchResultViewController:UITableViewDelegate,UITableViewDataSource {
    // MARK: - Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = results[indexPath.row]
        
        delegate?.GeneralSearchResultViewControllerDelegateDidChooseResult(self, result: result)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "detailCell")
        
        if cell == nil {cell = UITableViewCell(style: .subtitle, reuseIdentifier: "detailCell")}
        
        guard let cell = cell else {fatalError("Failed to create cell")}
        
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        let vm = results[indexPath.row]
        
        cell.textLabel?.text = vm.name
        
        let username = "@\(vm.username)"
        cell.detailTextLabel?.text = username
        
        return cell
    }
    
}


extension GeneralSearchResultViewController:UISearchResultsUpdating {
    
    // MARK: - Update Search result
    
    func updateSearchResults(for searchController: UISearchController) {
        task.cancel()
        guard let searchBarText = searchController.searchBar.text
        else { return }
        
        if searchBarText.isEmpty {
            results = []
            tableView.reloadData()
            return
        }
        
        task = .init(block: { [weak self] in
            self?.startSearch(searchBarText)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: task)
    }
    
    fileprivate func startSearch(_ searchBarText:String) {
        
        DatabaseManager.shared.searchForUsers(with: searchBarText) { [weak self] users in
            self?.results = users
            self?.tableView.reloadData()
        }
        
    }
}

