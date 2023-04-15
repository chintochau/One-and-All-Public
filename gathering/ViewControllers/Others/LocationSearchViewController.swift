//
//  LocationSearchViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-31.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationSerchViewControllerDelegate:AnyObject {
    func didChooseLocation(_ VC:LocationSearchViewController, location:Location)
}

class LocationSearchViewController: UIViewController {
    
    private let searchController:UISearchController = {
        let view = UISearchController(searchResultsController: LocationSearchResultTableVC())
        view.searchBar.placeholder = "搜尋地點..."
        view.obscuresBackgroundDuringPresentation = false
        return view
    }()
    
    private let mapView:MKMapView = {
        let view = MKMapView()
        var coordinate:CLLocationCoordinate2D = Location.torontoCoordinate
        if let location = UserDefaults.standard.string(forKey: UserDefaultsType.region.rawValue) {
            switch location {
//            case LocationSwitch.hongkong.rawValue:
//                coordinate = Location.hongkongCoordinate
            default:
                break
            }
        }
        let region = MKCoordinateRegion(center: coordinate, span: Location.span)
        view.setRegion(region, animated: true)
        return view
    }()
    
    weak var delegate:LocationSerchViewControllerDelegate?

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {  // must call from main thread
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    private func configureNavBar() {
        navigationItem.title = "地點"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = searchController.searchResultsController as? LocationSearchResultTableVC
        let resultVC = searchController.searchResultsController as! LocationSearchResultTableVC
        resultVC.delegate = self
        resultVC.mapView = mapView
    }
    
    @objc private func didTapClose(){
            self.dismiss(animated: true)
    }
    
}


extension LocationSearchViewController:LocationSearchResultTableVCDelegate {
    func LocationSearchResultDidChooseResult(_ VC: LocationSearchResultTableVC, location: Location) {
        dismiss(animated: false)
        dismiss(animated: true)
        print(location)
        delegate?.didChooseLocation(self, location: location)
    }
}
