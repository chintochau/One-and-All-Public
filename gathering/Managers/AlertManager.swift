//
//  AlertManager.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-24.
//

import UIKit

struct AlertManager {
    // Singleton instance
    static let shared = AlertManager()
    
    
    func showAlert(title: String, message: String, from viewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "確認", style: .default) { _ in
            completion?(true)
        }
        alert.addAction(dismissAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    
    func showAlert(title: String, message: String = "", buttonText: String, buttonStyle:UIAlertAction.Style = .default, cancelText: String? = "取消", from viewController: UIViewController, buttonCompletion: @escaping () -> Void, cancelCompletion: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelText = cancelText {
            let cancelAction = UIAlertAction(title: cancelText, style: .cancel) { _ in
                cancelCompletion?()
            }
            alertController.addAction(cancelAction)
        }
        
        let buttonAction = UIAlertAction(title: buttonText, style: buttonStyle) { _ in
            buttonCompletion()
        }
        alertController.addAction(buttonAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }

    
    func showActionSheet(withTitle title: String?, message: String?, firstButtonTitle: String, firstButtonAction: (() -> Void)? = nil, secondButtonTitle: String, secondButtonAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // Add the first button
        let firstButton = UIAlertAction(title: firstButtonTitle, style: .default) { _ in
            // Call the first button closure if it exists
            firstButtonAction?()
        }
        alertController.addAction(firstButton)
        
        // Add the second button
        let secondButton = UIAlertAction(title: secondButtonTitle, style: .default) { _ in
            // Call the second button closure if it exists
            secondButtonAction?()
        }
        alertController.addAction(secondButton)
        
        // Add a cancel button
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelButton)
        
        // Find the topmost window to present the alert
        if let topWindow = UIApplication.shared.windows.last {
            topWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    func reportPost(username:String, eventID: String, referencePath: String, viewController:UIViewController) {
        
        let alertController = UIAlertController(title: "回報", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let blockAction = UIAlertAction(title: "封鎖用戶: @\(username)", style: .default) { _ in
            
            showReportedMessage(message: "已封鎖用戶", viewController: viewController)
            RealmManager.shared.blockUser(targetUsername: username)
            
            if let viewController = viewController as? NewHomeViewController {
                print(123)
            }
            
            
        }
        let reportAction = UIAlertAction(title: "回報不當內容", style: .destructive) { _ in
            
            showReportedMessage(message: "感謝您回報不當的貼文！我們會盡快處理該貼文並採取必要的行動。",viewController: viewController)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(blockAction)
        alertController.addAction(reportAction)
        
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func showReportedMessage(message:String, viewController:UIViewController) {
        // Create the bubble message
        let reportedMessage = message
        
        let bubbleView = UIView()
        bubbleView.backgroundColor = .systemBackground
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        
        let reportedBubble = UILabel()
        reportedBubble.text = reportedMessage
        reportedBubble.font = .helvetica(ofSize: 15)
        reportedBubble.textColor = .label
        reportedBubble.textAlignment = .center
        reportedBubble.layer.cornerRadius = 10
        reportedBubble.clipsToBounds = true
        reportedBubble.numberOfLines = 2
        
        // Add the bubble to the view
        
        guard let view = viewController.view else {return}
        
        bubbleView.addSubview(reportedBubble)
        view.addSubview(bubbleView)
        reportedBubble.anchor(top: bubbleView.topAnchor, leading: bubbleView.leadingAnchor, bottom: bubbleView.bottomAnchor, trailing: bubbleView.trailingAnchor, padding: .init(top: 5, left: 10, bottom: 5, right: 10))
        bubbleView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor,padding: .init(top: 90, left: 30, bottom: 2, right: 30))
        
        // Set up auto-dismissal after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.5, animations: {
                reportedBubble.alpha = 0
                bubbleView.alpha  = 0
            }, completion: { finished in
                bubbleView.removeFromSuperview()
                reportedBubble.removeFromSuperview()
            })
        }
    }
    
    func showTextInputAlert(title: String, message: String?, placeholder: String, buttonMessage:String ,isDestructive:Bool = false, completion: @escaping (String?, _ didTapConfirm:Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        let okAction = UIAlertAction(title: buttonMessage, style: isDestructive ? .destructive : .default) { (_) in
            let text = alertController.textFields?.first?.text
            
            completion(text,true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            completion(nil,false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        if let topWindow = UIApplication.shared.windows.last {
            topWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

}
