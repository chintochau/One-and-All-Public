//
//  LoadingIndicator.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-08.
//


import UIKit

class LoadingIndicator {
    static let shared = LoadingIndicator()
    
    private let overlayView = UIView(frame: UIScreen.main.bounds)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private init() {
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
    }
    
    func showLoadingIndicator(on view: UIView) {
        overlayView.frame = view.bounds
        view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
