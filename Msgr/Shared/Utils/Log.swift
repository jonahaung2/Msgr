//
//  Log.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/12/22.
//

import Foundation

public func Log<T>(_ object: T?, filename: String = #file, line: Int = #line, funcname: String = #function) {
#if DEBUG
    guard let object = object else { return }
    print("> \(funcname),  \(filename.components(separatedBy: "/").last ?? ""),  Line: \(line),  Object: \(object)")
#endif
}
