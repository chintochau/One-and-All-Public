//
//  UIViewController+extension.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-14.
//
import UIKit
import Hero


extension UIViewController {
    
    
    func presentModallyWithHero(_ viewController: UIViewController) {
        let navVc = UINavigationController(rootViewController: viewController)
        navVc.hero.isEnabled = true
        navVc.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
        navVc.modalPresentationStyle = .fullScreen
        navVc.navigationBar.tintColor = .label
        present(navVc, animated: true)
    }
    
    
    func presentEventDetailViewController(eventID: String, eventRef: String) {
        let eventViewController = EventDetailViewController()
        eventViewController.configureWithID(eventID: eventID, eventReferencePath: eventRef)
        let navVc = UINavigationController(rootViewController: eventViewController)
        navVc.hero.isEnabled = true
        navVc.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
        navVc.modalPresentationStyle = .fullScreen
        navVc.navigationBar.tintColor = .label
        
        
        
        present(navVc, animated: true)
    }
    
    func setUpBackButtonOnNavBar(){
        navigationController?.navigationBar.tintColor = .label
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(handleBackForBackButton))
    }
    
    @objc func handleBackForBackButton (){
        dismiss(animated: true)
    }
    /// setup a panBackGesture
    func setUpPanBackGestureAndBackButton(){
        setUpBackButtonOnNavBar()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        let progress = translation.x / view.bounds.width
        
        switch gestureRecognizer.state {
        case .began:
            dismiss(animated: true, completion: nil)
        case .changed:
            
            Hero.shared.update(progress)
            let translation = gestureRecognizer.translation(in: nil)
            let relativeTranslation = translation.x / view.bounds.width
            let newProgress = max(0, min(1, relativeTranslation))
            Hero.shared.apply(modifiers: [.position(CGPoint(x: view.center.x, y: translation.y))], to: view)
            Hero.shared.update(newProgress)
        case .ended, .cancelled:
            if progress + gestureRecognizer.velocity(in: view).x / view.bounds.width > 0.5 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        default:
            break
        }
    }
    
    
    func enableSwipeBackNavigation() {
        // Add custom gesture recognizer for swipe back navigation
        let swipeBackGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeBackGesture(_:)))
        swipeBackGesture.edges = .left
        view.addGestureRecognizer(swipeBackGesture)
    }
    
    @objc func handleSwipeBackGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            navigationController?.popViewController(animated: true)
        }
    }
    
}

