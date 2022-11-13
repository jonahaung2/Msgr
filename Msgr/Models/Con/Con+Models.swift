//
//  Con+Models.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

extension Con {
    enum BgImage: Int16, CaseIterable, Identifiable {
        var id: Int16 { rawValue }
        case None, One, White, Blue, Brown

        var name: String { "chatBg\(rawValue)" }

        var image: some View {
            Group {
                if self != .None {
                    Image(name)
                        .resizable()
                        .clipped()
                } else {
                    ChatBackground()
                }
            }
        }
    }

    enum ThemeColor: Int16, CaseIterable, Identifiable {
        var id: Int16 { rawValue }
        case Blue, Orange, Yellow, Green, Mint, Teal, Cyan, Red, Indigo, Purple, Pink, Brown, Gray

        var name: String {
            "\(self)"
        }

        var color: Color {
            switch self {
            case .Blue:
                return .blue
            case .Orange:
                return .orange
            case .Yellow:
                return .yellow
            case .Green:
                return .green
            case .Mint:
                return .mint
            case .Teal:
                return .teal
            case .Cyan:
                return .cyan
            case .Red:
                return .red
            case .Indigo:
                return .indigo
            case .Purple:
                return .purple
            case .Pink:
                return .pink
            case .Brown:
                return .brown
            case .Gray:
                return .gray
            }
        }
    }
}

extension Color {

    func uiColor() -> UIColor {

        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}
