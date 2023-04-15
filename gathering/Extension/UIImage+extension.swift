//
//  UIImage+extension.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-02.
//

import UIKit

extension UIView {
    func createAttributedText(with text: String, imageName: String) -> NSAttributedString {
        let fullString = NSMutableAttributedString(string: "  \(text)")
        let imageAttachment = NSTextAttachment()
        let image = UIImage(systemName: imageName)!.withTintColor(.mainColor)
        imageAttachment.image = image
        
        let font = UIFont.systemFont(ofSize: 17) // adjust to the font size you are using
        let mid = font.descender + font.capHeight // calculate the midpoint of the font
        imageAttachment.bounds = CGRect(x: 0, y: mid - image.size.height / 2, width: image.size.width, height: image.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        fullString.replaceCharacters(in: NSRange(location: 0, length: 1), with: imageString)
        return fullString
    }
    
    
    func createAttributedText(with text: String, image: UIImage, color:UIColor? = nil) -> NSAttributedString {
        let fullString = NSMutableAttributedString(string: "  \(text)")
        let imageAttachment = NSTextAttachment()
        if let color = color {
            imageAttachment.image = image.withTintColor(color)
        }else {
            imageAttachment.image = image
        }
        let font = UIFont.systemFont(ofSize: 17) // adjust to the font size you are using
        let mid = font.descender + font.capHeight // calculate the midpoint of the font
        imageAttachment.bounds = CGRect(x: 0, y: mid - image.size.height / 2, width: image.size.width, height: image.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        fullString.replaceCharacters(in: NSRange(location: 0, length: 1), with: imageString)
        return fullString
    }
}

extension UIImage {
    static let personIcon = UIImage(systemName: "person.circle")
    
    static let locationIcon:UIImage = {
        return UIImage(named: "locationSymbol")!
    }()
    
    static let dateIcon:UIImage = {
        return UIImage(named: "dateSymbol")!
    }()
    
    static let timeIcon:UIImage = {
        return UIImage(named: "timeSymbol")!
    }()
    static let messageIcon:UIImage = {
        return UIImage(named: "messageSymbol")!
    }()
    static let participantsIcon:UIImage = {
        return UIImage(named: "participantSymbol")!
    }()
    
    static let femaleIcon:UIImage = {
        return UIImage(named: "femaleSymbol")!
    }()
    
    static let maleIcon:UIImage = {
        return UIImage(named: "maleSymbol")!
    }()
    
    
    
}
