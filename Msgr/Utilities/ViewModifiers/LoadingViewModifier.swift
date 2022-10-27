//
//  LoadingViewModifier.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 4/9/22.
//

import SwiftUI

public struct LoadingViewModifier: ViewModifier {
    var isLoading: Bool
    public func body(content: Content) -> some View {
        content
          .redacted(reason: isLoading ? [.placeholder] : [])
          .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }
}

public extension View {
    func loadiable(_ isLoading: Bool) -> some View {
        ModifiedContent(content: self, modifier: LoadingViewModifier(isLoading: isLoading))
    }
}
