//
//  XColor.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 24/4/22.
//

import SwiftUI

public struct XColor {

    static func randomColor(seed: String) -> UIColor {
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    public struct Light {
        public static let red = Color(hex: 0xF5BCBC)
        public static let orange = Color(hex: 0xFDD0B2)
        public static let yellow = Color(hex: 0xFCE8B2)
        public static let green = Color(hex: 0xD3F2B2)
        public static let cyan = Color(hex: 0xC6F3E9)
        public static let sky = Color(hex: 0xC1EDFF)
        public static let blue = Color(hex: 0xB2DEFF)
        public static let purple = Color(hex: 0xCFC2FF)
        public static let pink = Color(hex: 0xE9BCF5)
        public static let gray = Color(hex: 0xD3D4D6)
        public static let lightgray = Color(hex: 0xE9E9E9)
        
       static let allColors = [.clear, blue, orange, yellow, green, cyan, sky, blue, purple, pink, gray, lightgray]
        
        public static func random() -> Color {
            return allColors.randomElement() ?? gray
        }
    }
    public struct UI {
        public static let red = Color.red
        public static let orange = Color.orange
        public static let yellow = Color.yellow
        public static let green = Color.green
        public static let cyan = Color.cyan
        public static let teal = Color.teal
        public static let blue = Color.blue
        public static let purple = Color.purple
        public static let pink = Color.pink
        public static let gray = Color.gray
        public static let mint = Color.mint
        public static let indigo = Color.indigo
        
       static let allColors = [.sectionBackground, blue, orange, yellow, green, cyan, teal, red, purple, pink, gray, mint, indigo]
        
        public static func random() -> Color {
            return allColors.randomElement() ?? gray
        }
    }
    public static let black = Color(hex: 0x000000)
}

extension UIColor {
    convenience init(hex: Int) {
        var red: CGFloat = 1
        var green: CGFloat = 1
        var blue: CGFloat = 1
        var alpha: CGFloat = 1
        
        if hex <= 0xFFFFFF {
            red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
            blue = CGFloat((hex & 0x0000FF) >> 0) / 255.0
        } else {
            red = CGFloat((hex & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hex & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat((hex & 0x000000FF) >> 0) / 255.0
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Color {
    init(hex: Int) {
        self.init(UIColor(hex: hex))
    }

   static let sectionBackground: Color = Color(uiColor: .secondarySystemGroupedBackground)
   static let background: Color = Color(uiColor: .systemBackground)
}

extension UIColor {
    var color: Color { .init(uiColor: self)}
}

enum TintColor: String, CaseIterable {

    case blue, red, pink, green, orange, yellow, cyan, teal, mint, purple, indingo, brown
    var color: Color {
        switch self {
        case .blue:
            return Color.blue
        case .red:
            return .red
        case .pink:
            return .pink
        case .green:
            return .green
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .cyan:
            return .cyan
        case .teal:
            return .teal
        case .mint:
            return .mint
        case .purple:
            return .purple
        case .indingo:
            return .indigo
        case .brown:
            return .brown
        }
    }
}
