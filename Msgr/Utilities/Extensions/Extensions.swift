//
//  Extensions.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import Foundation
import SwiftUI


extension View {
    func frame(size: CGSize?) -> some View {
        self.frame(width: size?.width, height: size?.height)
    }
}

extension CGSize {
    init(size: CGFloat) {
        self.init(width: size, height: size)
    }
}

extension String: Identifiable {
    public var id: String { self }
}

extension Double {
    var int: Int { Int(self) }
}
extension Int {
    var double: Double { Double(self) }
}
extension Int16 {
    var cgFloat: CGFloat {
        CGFloat(self)
    }
    var double: Double {
        Double(self)
    }
}
extension String {
   func localized(with separator: Character) -> String {
       return self
           .split(separator: separator)
           .joined(separator: " ")
   }

    var isWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func contains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }


    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

extension String {
    static var alphabeta: [String] {
        var chars = [String]()
        for char in "abcdefghijklmnopqrstuvwxyz#".uppercased() {
            chars.append(String(char))
        }
        return chars
    }
}
