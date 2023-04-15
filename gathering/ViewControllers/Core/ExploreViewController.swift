//
//  ExploreViewController.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import UIKit
import MapKit
import CoreLocation


class ExploreViewController: UIViewController {
    
    private let searchController:UISearchController = {
        let view = UISearchController(searchResultsController: GeneralSearchResultViewController())
        view.searchBar.searchTextField.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.8)
        view.searchBar.placeholder = "Search user/ events/ location..."
        return view
    }()
    
    
    lazy var segmentedButtonsView:SegmentedButtonsView = {
        let segmentedButtonsView = SegmentedButtonsView()
        segmentedButtonsView.setLablesTitles(titles: ["Users"])
        return segmentedButtonsView
    }()
    
    
    private let titleLabel : UILabel = {
        let view = UILabel()
        view.text = "NearBy"
        view.font = .righteousFont(ofSize: 24)
        view.textColor = .label
        return view
    }()
    
    private let mapView:MKMapView = {
        let view = MKMapView()
        let region = MKCoordinateRegion(center: Location.torontoCoordinate, span: Location.span)
        view.setRegion(region, animated: true)
        return view
    }()
    
    
    private var collectionView:UICollectionView!
    
    private let locationManager = CLLocationManager()
    private var users:[User] = []
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchUsersDate()
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //        configureMap()
        //        requestLocationAuth()
        configureSearchBar()
        //        definesPresentationContext = true
    }
    
    private func fetchUsersDate(){
        DatabaseManager.shared.searchForUsers(with: "") { users in
            self.users = users
            self.collectionView.reloadData()
        }
    }
    
    private func configureCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.width - 30)/2, height: (view.width - 30)/2)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        let view = UICollectionView(frame: .zero,collectionViewLayout: layout)
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.register(UserMediumCollectionViewCell.self, forCellWithReuseIdentifier: UserMediumCollectionViewCell.identifier)
        self.collectionView = view
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centreOnUserLoction()
    }
    
    
    
    
}

extension ExploreViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    
    // MARK: - Filter Tab
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserMediumCollectionViewCell.identifier, for: indexPath) as! UserMediumCollectionViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = true
    }
    
}

extension ExploreViewController : GeneralSearchResultViewControllerDelegate{
    
    func GeneralSearchResultViewControllerDelegateDidChooseResult(_ view: GeneralSearchResultViewController, result: User) {
        let vc = UserProfileViewController(user: result)
        vc.title = "Profile"
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    
    // MARK: - Search Bar
    
    private func configureSearchBar(){
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
        headerView.addSubview(titleLabel)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 0, y: 0, width: titleLabel.width, height: 44)
        
    }
}

extension ExploreViewController:CLLocationManagerDelegate {
    // MARK: - Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        let centre = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion.init(center: centre, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func centreOnUserLoction() {
        if let location = locationManager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            let region = MKCoordinateRegion.init(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    }
    
}

extension ExploreViewController:MKMapViewDelegate {
    // MARK: - Map
    
    fileprivate func requestLocationAuth() {
        DispatchQueue.global().async{
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.delegate = self
            }
        }
    }
    
    
    fileprivate func configureMap() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
}

