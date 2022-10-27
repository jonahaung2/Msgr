//
//  CancelButton.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 2/5/22.
//

import SwiftUI

struct CancelButton: View {
    
    @Environment(\.dismiss) var dismiss
    let isProtected: Bool
    
    var body: some View {
        Group {
            if isProtected {
                Text("Cancel")
                    .tapToShowComfirmationDialog(dialog: .init(message: "Are you sure you want to quit?", items: [.init(title: "Discard and Quit", role: .destructive, action: quitAction)]))
            } else {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        
    }
    
    private func quitAction() {
        dismiss()
    }
}
