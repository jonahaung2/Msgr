//
//  Extensions.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import Foundation
import SwiftUI

extension View {
    var any: AnyView { AnyView(self) }
}

// Extensions
private struct FrameSize: ViewModifier {
    let size: CGSize?

    func body(content: Content) -> some View {
        content
            .frame(width: size?.width, height: size?.height)
    }
}
extension View {
    func frame(size: CGSize?) -> some View {
        return modifier(FrameSize(size: size))
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

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Optional where Wrapped == String {
    var str: String {
        return self ?? ""
    }
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

    var urlDecoded: String {
        removingPercentEncoding ?? self
    }

    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }

    var isWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var whiteSpace: String {
        appending(" ")
    }
    func prepending(_ string: String) -> String {
        string + self
    }
    var newLine: String {
        appending("\r")
    }

    var nonLineBreak: String {
        replacingOccurrences(of: " ", with: "\u{00a0}")
    }

    func contains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }

    func lines() -> [String] {
        var result = [String]()
        enumerateLines { line, _ in
            result.append(line)
        }
        return result
    }

    func words() -> [String] {
        let comps = components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return comps.filter { !$0.isWhitespace }
    }

    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    func withoutSpaces() -> String {
        trimmingCharacters(in: .whitespaces)
    }
}
extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
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

extension Array {
    func slice(size: Int) -> [[Element]] {
        (0...(count / size)).map{Array(self[($0 * size)..<(Swift.min($0 * size + size, count))])}
    }
}


extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
