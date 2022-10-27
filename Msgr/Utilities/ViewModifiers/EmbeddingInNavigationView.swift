//
//  EmbeddingInNavigationView.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 2/5/22.
//

import SwiftUI
public struct EmbeddingInNavigationViewModifier: ViewModifier {
    let canCancel: Bool
    @AppStorage(UserDefaultManager.shared.Tint_Color) private var tintColor: TintColor = .blue
    @AppStorage(UserDefaultManager.shared.Is_Dark_Mode) private var isDarkMode = false

    public func body(content: Content) -> some View {
        PickerNavigationView(canCancel: canCancel) {
            content
        }
        .accentColor(tintColor.color)
        .colorScheme(isDarkMode ? .dark : .light)
    }
}

public extension View {
    func embeddedInNavigationView(canCancel: Bool = false) -> some View {
        ModifiedContent(content: self, modifier: EmbeddingInNavigationViewModifier(canCancel: canCancel))
    }
}
