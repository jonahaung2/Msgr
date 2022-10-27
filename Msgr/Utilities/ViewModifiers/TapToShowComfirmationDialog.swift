//
//  TapToShowComfirmationDialog.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 5/4/22.
//

import SwiftUI

public struct TapToShowComfirmationDialogStyle: ViewModifier {
    
    public let dialog: ConfirmationDialog
    @State private var show = false
    
    public func body(content: Content) -> some View {
        Button {
            show = true
        } label: {
            content
        }
        .confirmationDialog(dialog.title, isPresented: $show) {
            ForEach(dialog.items) {
                $0.button
            }
        } message: {
            Text(dialog.message)
        }
    }
}

public struct ConfirmationDialog {
    public var title = "Attention"
    public var message = ""
    public var items: [ButtonItem]
}

public struct ButtonItem: Identifiable {
    public var id = UUID()
    public let title: String
    public var role: ButtonRole? = .none
    public let action: () -> Void
    
    public var button: some View {
        Button(title, role: role, action: action)
    }
}

public extension View {
    func tapToShowComfirmationDialog(dialog: ConfirmationDialog) -> some View {
        ModifiedContent(content: self, modifier: TapToShowComfirmationDialogStyle(dialog: dialog))
    }
}
