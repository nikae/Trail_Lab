//
//  Color.swift
//  Trail Lab
//
//  Created by Nika on 6/9/20.
//  Copyright © 2020 nilka. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIColor {
    #if os(iOS)
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return light }
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
    #endif
}

extension UIColor {
    #if os(iOS)
    struct background {
        static let primary = dynamicColor(
            light: .white,
            dark: UIColor(netHex: 0x1C1C1D))
        static let primaryDark = dynamicColor(
            light: .white,
            dark: UIColor(netHex: 0x050505))
        static let secondary =  dynamicColor(
            light: .secondarySystemBackground,
            dark: UIColor(netHex: 0x454547))
        static let accentColor =  dynamicColor(
                   light: UIColor(netHex: 0x454547),
                   dark: UIColor(netHex: 0x525254))
    }
    
#endif

    struct SportColors {
        static let run = UIColor(red: 254/255.0, green: 220/255.0, blue: 40/255.0, alpha: 1) //#FEDC28
        static let walk = UIColor(red: 255/255.0, green: 118/255.0, blue: 94/255.0, alpha: 1) //#FF765E
        static let hike = UIColor(red: 147/255.0, green: 201/255.0, blue: 106/255.0, alpha: 1) //#93C96A
        static let bike = UIColor(red: 100/255.0, green: 185/255.0, blue: 190/255.0, alpha: 1) //#64B9BE
    }
}


extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }
        return (r, g, b, o)
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> Color {
        return Color(red: min(Double(self.components.red + percentage/100), 1.0),
                     green: min(Double(self.components.green + percentage/100), 1.0),
                     blue: min(Double(self.components.blue + percentage/100), 1.0),
                     opacity: Double(self.components.opacity))
    }
}
