//
//  Extension.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import Foundation
import UIKit
import Hero

extension UIView {
    var top: CGFloat {
        frame.origin.y
    }
    var bottom: CGFloat {
        frame.origin.y + height
    }
    var left: CGFloat  {
        frame.origin.x
    }
    var right: CGFloat  {
        frame.origin.x + width
    }
    var width: CGFloat {
        frame.size.width
    }
    var height: CGFloat {
        frame.size.height
    }
    
    
    func fillSuperview() {
        anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    
    func anchorSize(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero){
        translatesAutoresizingMaskIntoConstraints = false
        
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            let heightConstrant = heightAnchor.constraint(equalToConstant: size.height)
            heightConstrant.priority = .defaultHigh
            heightConstrant.isActive = true
        }
    }
    
    func flexibleAnchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero){
        translatesAutoresizingMaskIntoConstraints = false
        
        
        if let top = top {
            let topConstraint = topAnchor.constraint(equalTo: top, constant: padding.top)
            topConstraint.priority = .defaultHigh
            topConstraint.isActive = true
        }
        
        if let leading = leading {
            let leadingConstraint = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
            leadingConstraint.priority = .defaultHigh
            leadingConstraint.isActive = true
        }
        
        if let bottom = bottom {
            let bottomConstraint = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
        }
        
        if let trailing = trailing {
            let trailConstraint = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
            trailConstraint.priority = .defaultHigh
            trailConstraint.isActive = true
        }
        
        if size.width != 0 {
            let widthConstrant = widthAnchor.constraint(equalToConstant: size.width)
            widthConstrant.priority = .defaultHigh
            widthConstrant.isActive = true
        }
        
        if size.height != 0 {
            let heightConstrant = heightAnchor.constraint(equalToConstant: size.height)
            heightConstrant.priority = .defaultHigh
            heightConstrant.isActive = true
        }
    }
    
    
    
}



extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}



extension Decodable {
    ///Change Dictionary to a decodable Data type
    init?(with dictionary: [String:Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {return nil}
        guard let result = try? JSONDecoder().decode(Self.self, from: data) else {return nil}
        self = result
    }
}


extension Encodable {
    /// convert a codable object into Dictionary
    func asDictionary() -> [String:Any]? {
        guard let data = try? JSONEncoder().encode(self) else {return nil}
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
        return json
    }
}

extension DateFormatter {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}





extension Double {
    static func todayAtMidnightTimestamp() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 00:00:00"
        let dateString = dateFormatter.string(from: Date())
        let todayAtMidnight = dateFormatter.date(from: dateString)
        
        return todayAtMidnight!
    }
}


enum LocaleIdentifier: String {
    case enUS = "en_US"
    case esES = "es_ES"
    case frFR = "fr_FR"
    case deDE = "de_DE"
    case jaJP = "ja_JP"
    case zhHansCN = "zh_Hans_CN"
    case zhHantTW = "zh_Hant_TW"
    case arAE = "ar_AE"
    case ruRU = "ru_RU"
    case hiIN = "hi_IN"
}


extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}



extension UILabel {
    /// count lines that get drawn
    func countLines() -> Int {
        guard let myText = self.text as NSString? else {
            return 0
        }
        // Call self.layoutIfNeeded() if your view uses auto layout
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil)
        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
}

extension UITableViewCell {
    func separator(hide: Bool) {
        separatorInset.left = hide ? bounds.size.width : 0
    }
}



#if DEBUG
import SwiftUI
import Hero

@available(iOS 13, *)
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        // this variable is used for injecting the current view controller
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        // inject self (the current view controller) for the preview
        Preview(viewController: self)
    }
}
#endif
