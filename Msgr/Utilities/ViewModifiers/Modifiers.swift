//
//  Modifiers.swift
//  Msgr
//
//  Created by Aung Ko Min on 10/12/22.
//

import SwiftUI

// Modifier for adding shadow and corner radius to a view.
struct ShadowViewModifier: ViewModifier {

    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content.background(Color(UIColor.systemBackground))
            .cornerRadius(cornerRadius)
            .modifier(ShadowModifier())
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color(UIColor.opaqueSeparator),
                        lineWidth: 0.5
                    )
            )
    }
}

/// Modifier for adding shadow to a view.
public struct ShadowModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

/// View modifier that applies default padding to elements.
struct StandardPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}

struct RoundedBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = 18
    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct IconOverImageModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .foregroundColor(.accentColor)
            .padding(.all, 4)
    }
}

extension View {
    /// View extension that applies default padding to elements.
    public func standardPadding() -> some View {
        modifier(StandardPaddingModifier())
    }

    public func roundWithBorder(cornerRadius: CGFloat = 18) -> some View {
        modifier(RoundedBorderModifier(cornerRadius: cornerRadius))
    }

    public func applyDefaultIconOverlayStyle() -> some View {
        modifier(IconOverImageModifier())
    }
}
