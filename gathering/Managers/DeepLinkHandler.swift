//
//  DeepLinkHandler.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-04.
//

import UIKit

protocol DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool
    func openURL(_ url: URL)
}

protocol DeeplinkCoordinatorProtocol {
    @discardableResult
    func handleURL(_ url: URL) -> Bool
}

final class DeeplinkCoordinator {
    
    let handlers: [DeeplinkHandlerProtocol]
    
    init(handlers: [DeeplinkHandlerProtocol]) {
        self.handlers = handlers
    }
}

extension DeeplinkCoordinator: DeeplinkCoordinatorProtocol {
    
    @discardableResult
    func handleURL(_ url: URL) -> Bool{
        guard let handler = handlers.first(where: { $0.canOpenURL(url) }) else {
            return false
        }
              
        handler.openURL(url)
        return true
    }
}


// MARK: - Event Deep Link
final class EventDeeplinkHandler: DeeplinkHandlerProtocol {
    
    static func generateEventDeepLink (with event:Event) -> String {
         
        guard let ref = event.referencePath else {
            fatalError()
        }
        let prefix = "gathereventca://event"
        let eventID = event.id
        // "GatherEventCa://event?eventId=jjj_1677983207.779362_361&Ref=events/202309"
        
        return "\(prefix)?eventId=\(eventID)&Ref=\(ref)"
    }
    
    private weak var rootViewController: UIViewController?
    
    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    // MARK: - DeeplinkHandlerProtocol
    
    func canOpenURL(_ url: URL) -> Bool {
        
        return url.absoluteString.hasPrefix("gathereventca://event")
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let eventId = components.queryItems?.first(where: { $0.name == "eventId" })?.value,
              let ref = components.queryItems?.first(where: { $0.name == "Ref" })?.value else {
            return
        }
        
        let eventViewController = EventDetailViewController()
        eventViewController.configureWithID(eventID: eventId, eventReferencePath: ref)
        let navVc = UINavigationController(rootViewController: eventViewController)
        navVc.hero.isEnabled = true
        navVc.hero.modalAnimationType = .autoReverse(presenting: .push(direction: .left))
        navVc.modalPresentationStyle = .fullScreen
        
        
        
        if let mainTabBarVC = rootViewController as? TabBarViewController {
            mainTabBarVC.selectedIndex = 0
            if let homeNavVC = mainTabBarVC.viewControllers?.first as? UINavigationController {
                homeNavVC.present(navVc, animated: true)
                
                
            }
        }
        
        
    }
}
