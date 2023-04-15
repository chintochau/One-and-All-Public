//
//  SceneDelegate.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-10.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    lazy var deeplinkCoordinator: DeeplinkCoordinatorProtocol = {
            return DeeplinkCoordinator(handlers: [
                EventDeeplinkHandler(rootViewController: self.rootViewController)
//               , VideoDeeplinkHandler(rootViewController: self.rootViewController)
            ])
        }()
    
    var rootViewController: UIViewController? {
            return window?.rootViewController
        }
    
    func show(_ url: URL) {
        let alert = UIAlertController(title: "Got one!", message: url.path, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.window?.rootViewController?.present(alert, animated: true)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        
        // MARK: - Initial screen
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let rootVC = TabBarViewController()
        
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        self.window = window
        
        
        if let url = connectionOptions.urlContexts.first?.url {
            self.deeplinkCoordinator.handleURL(url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let firstUrl = URLContexts.first?.url else {
            return
        }
        
        deeplinkCoordinator.handleURL(firstUrl)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}


