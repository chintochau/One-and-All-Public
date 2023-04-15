//
//  SearchResultViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-31.
//

import UIKit
import MapKit

protocol LocationSearchResultTableVCDelegate:AnyObject {
    func LocationSearchResultDidChooseResult(_ VC:LocationSearchResultTableVC,location:Location)
}

class LocationSearchResultTableVC: UIViewController {
    
    weak var  delegate:LocationSearchResultTableVCDelegate?
    
    let tableView:UITableView = {
        let view = UITableView()
        return view
    }()
    
    private var task = DispatchWorkItem{}
    var mapView: MKMapView? = nil
    
    var customLocation:String = ""
    var matchingItems:[MKMapItem] = []
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
}


extension LocationSearchResultTableVC:UITableViewDelegate,UITableViewDataSource {
    // MARK: - Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : matchingItems.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var location:Location!
        if indexPath.section == 0 {
            location = .init(
                name: customLocation,
                address: nil,
                latitude: nil,
                longitude: nil)
        }else {
            location = Location(with: matchingItems[indexPath.row])
        }
        delegate?.LocationSearchResultDidChooseResult(self,location:location)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "detailCell")
        
        if cell == nil {cell = UITableViewCell(style: .subtitle, reuseIdentifier: "detailCell")}
        
        guard let cell = cell else {fatalError("Failed to create cell")}
        
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        if indexPath.section == 0 {
            cell.textLabel?.text = customLocation
            cell.detailTextLabel?.text = "Custom Location"
            return cell
        }
        
        let vm = matchingItems[indexPath.row]
        let address = formatMapItem(vm)
        
        cell.textLabel?.text = address.locationName
        cell.detailTextLabel?.text = address.address
        
        return cell
    }
    
    private func formatMapItem(_ mapItem: MKMapItem) -> (locationName: String, address: String) {
        let locationName = mapItem.name ?? ""
        let placemark = mapItem.placemark
        var address = ""
        
        if let streetNumber = placemark.subThoroughfare,
           let streetName = placemark.thoroughfare {
            address += "\(streetNumber) \(streetName)"
        } else if let streetName = placemark.thoroughfare {
            address += "\(streetName)"
        }
        
        if let city = placemark.locality {
            if !address.isEmpty {
                address += ", "
            }
            address += "\(city)"
        }
        
        if let state = placemark.administrativeArea {
            if !address.isEmpty {
                address += ", "
            }
            address += "\(state)"
        }
        
        if let postalCode = placemark.postalCode {
            if !address.isEmpty {
                address += " "
            }
            address += "\(postalCode)"
        }
        
        return (locationName, address)
    }

    
}

extension LocationSearchResultTableVC:UISearchResultsUpdating {
    
    // MARK: - Update Search result
    
    func updateSearchResults(for searchController: UISearchController) {
        task.cancel()
        guard let searchBarText = searchController.searchBar.text
        else { return }
        
        if searchBarText.isEmpty {
            matchingItems = []
            tableView.reloadData()
        }
        customLocation = searchBarText
        tableView.reloadData()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        
        
        
        var coordinate:CLLocationCoordinate2D = Location.torontoCoordinate
        if let location = UserDefaults.standard.string(forKey: UserDefaultsType.region.rawValue) {
            switch location {
//            case LocationSwitch.hongkong.rawValue:
//                coordinate = Location.hongkongCoordinate
            default:
                break
            }
        }
        
        
        request.region = .init(center: coordinate, span: Location.span)
        let search = MKLocalSearch(request: request)
        
        task = .init(block: { [weak self] in
            self?.startSearch(search)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: task)
    }
    
    fileprivate func startSearch(_ search: MKLocalSearch) {
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

