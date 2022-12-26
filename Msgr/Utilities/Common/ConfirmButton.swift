//
//  ComfirmButton.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 8/5/22.
//

import SwiftUI
struct ConfirmButton<Content: View>: View {

    let title: String
    let action: () -> Void
    @ViewBuilder var label: () -> Content

    @State private var showDialog = false
    
    var body: some View {
        Button {
            showDialog = true
        } label: {
            label()
        }
        .confirmationDialog("Dialog", isPresented: $showDialog, actions: {
            Button(role: .destructive, action: action) {
                Text("Yes \(title)")
            }
        }, message: {
            Text("Are you sure you want to \(title)?")
        })
        .labelsHidden()
    }
}
