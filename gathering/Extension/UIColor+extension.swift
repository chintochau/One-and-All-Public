//
//  UIColor+extension.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-28.
//

import UIKit


extension UIColor {
    convenience init(rgb: UInt) {
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(
            red: r / 255,
            green: g / 255,
            blue: b / 255,
            alpha: 1
        )
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(
            r: CGFloat(red),
            g: CGFloat(green),
            b: CGFloat(blue)
        )
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xff,
            green: (rgb >> 8) & 0xff,
            blue: rgb & 0xff
        )
    }
    
    static let mainColor = UIColor(named: "mainColor")!
    static let redColor = UIColor(named: "redColor")!
    static let blueColor = UIColor(named: "blueColor")!
    static let blackBackground = UIColor(named: "blackBackground")!
    static let lightMainColor = UIColor(named: "lightMainColor")!
    static let darkMainColor = UIColor(named: "darkMainColor")!
    static let darkSecondaryColor = UIColor(named: "darkSecondaryColor")!
    static let secondaryTextColor = UIColor(named: "secondaryTextColor")!
    static let lightFillColor = UIColor(named: "lightFillColor")!
    static let extraLightGray = UIColor(named: "extraLightGray")!
    static let tiffBlueColor = UIColor(named: "tiffBlueColor")!
    
    
    
    static let mainTextColor = UIColor(red: 0.00, green: 0.42, blue: 0.46, alpha: 1.00)
    
}

extension UIColor {
    /// This is color palette used by design team.
    /// If you see any color not from this list in figma, point it out to anyone in design team.
    static let streamBlack = mode(0x000000, 0xffffff)
    static let streamGray = mode(0x7a7a7a, 0x7a7a7a)
    static let streamGrayGainsboro = mode(0xdbdbdb, 0x2d2f2f)
    static let streamGrayWhisper = mode(0xecebeb, 0x1c1e22)
    static let streamDarkGray = mode(0x7a7a7a, 0x7a7a7a)
    static let streamWhiteSmoke = mode(0xf2f2f2, 0x13151b)
    static let streamWhiteSnow = mode(0xfcfcfc, 0x070a0d)
    static let streamOverlayLight = mode(0xfcfcfc, lightAlpha: 0.9, 0x070a0d, darkAlpha: 0.9)
    static let streamWhite = mode(0xffffff, 0x101418)
    static let streamBlueAlice = mode(0xe9f2ff, 0x00193d)
    static let streamAccentBlue = mode(0x005fff, 0x005fff)
    static let streamAccentRed = mode(0xff3742, 0xff3742)
    static let streamAccentGreen = mode(0x20e070, 0x20e070)
    static let streamGrayDisabledText = mode(0x72767e, 0x72767e)
    
    // Currently we are not using the correct shadow color from figma's color palette. This is to avoid
    // an issue with snapshots inconsistency between Intel vs M1. We can't use shadows with transparency.
    // So we apply a light gray color to fake the transparency.
    static let streamModalShadow = mode(0xd6d6d6, lightAlpha: 1, 0, darkAlpha: 1)
    
    static let streamWhiteStatic = mode(0xffffff, 0xffffff)
    
    static let streamBGGradientFrom = mode(0xf7f7f7, 0x101214)
    static let streamBGGradientTo = mode(0xfcfcfc, 0x070a0d)
    static let streamOverlay = mode(0x000000, lightAlpha: 0.2, 0x000000, darkAlpha: 0.4)
    static let streamOverlayDark = mode(0x000000, lightAlpha: 0.6, 0xffffff, darkAlpha: 0.8)
    static let streamOverlayDarkStatic = mode(0x000000, lightAlpha: 0.6, 0x000000, darkAlpha: 0.6)
    
    static func mode(_ light: Int, lightAlpha: CGFloat = 1.0, _ dark: Int, darkAlpha: CGFloat = 1.0) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? UIColor(rgb: dark).withAlphaComponent(darkAlpha)
                : UIColor(rgb: light).withAlphaComponent(lightAlpha)
            }
        } else {
            return UIColor(rgb: light).withAlphaComponent(lightAlpha)
        }
    }
}
