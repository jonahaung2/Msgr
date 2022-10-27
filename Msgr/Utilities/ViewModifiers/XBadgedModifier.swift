//
//  XBadgedModifier.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 23/9/22.
//

import SwiftUI

public struct XBadgedModifier: ViewModifier {
   let string: String
    public func body(content: Content) -> some View {
       HStack(alignment: .bottom, spacing: 4) {
          content
          Text(string)
             .font(.footnote)
             .italic()
             .foregroundStyle(.secondary)
        }
    }
}

public extension View {
   func xBadged(_ string: String) -> some View {
        ModifiedContent(content: self, modifier: XBadgedModifier(string: string))
    }
}



