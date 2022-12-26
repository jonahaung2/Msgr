//
//  Shared+Extensions.swift
//  Msgr
//
//  Created by Aung Ko Min on 9/12/22.
//

import Foundation

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

extension Optional where Wrapped == String {
    var str: String {
        return self ?? "nil"
    }
    func ifNil(_ str: String) -> String {
        return self ?? str
    }
}
extension Date {
    func convert(from initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(targetTimeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}

extension TimeZone {
    static let singapore: TimeZone = .init(identifier: "Asia/Singapore")!
}
