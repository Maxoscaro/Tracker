//
//  Emojis.swift
//  TrackerApp
//
//  Created by Maksim on 05.11.2024.
//

import UIKit

enum TrackerConstants {
    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    static let colors: [UIColor] = [
        .ypColorSelection1,
        .ypColorSelection2,
        .ypColorSelection3,
        .ypColorSelection4,
        .ypColorSelection5,
        .ypColorSelection6,
        .ypColorSelection7,
        .ypColorSelection8,
        .ypColorSelection9,
        .ypColorSelection10,
        .ypColorSelection11,
        .ypColorSelection12,
        .ypColorSelection13,
        .ypColorSelection14,
        .ypColorSelection15,
        .ypColorSelection16,
        .ypColorSelection17,
        .ypColorSelection18
    ]
}

extension UIColor {
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        let rgb: Int = (Int(red * 255) << 16) | (Int(green * 255) << 8) | Int(blue * 255)
        
        return String(format: "#%06X", rgb)
    }
        convenience init?(hexString: String) {
            var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            hex = hex.replacingOccurrences(of: "#", with: "")

            guard hex.count == 6 else { return nil }

            var rgbValue: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&rgbValue)

            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }

