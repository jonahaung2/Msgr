//
//  PickerNavigationView.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 25/3/22.
//

import SwiftUI

struct PickerNavigationView<Content: View>: View {
    var canCancel = true
    let content: () -> Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            content()
                .navigationBarItems(leading: Leading())
        }
    }
    private func Leading() -> some View {
        Group {
            if canCancel {
                CancelButton(dismiss: _dismiss, isProtected: false)
            }
        }
    }
}
