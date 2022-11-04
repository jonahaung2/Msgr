//
//  FormCell.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 25/4/22.
//

import SwiftUI

struct FormCell<Content: View>: View {
    let icon: XIcon.Icon
    var color = Color.secondary
    @ViewBuilder var content: () -> Content
    
    @ViewBuilder
    var body: some View {
        HStack(alignment: .bottom) {
            XIcon(icon)
                .foregroundColor(color)
                .frame(width: 25, height: 25)
            content()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct FormCell2<Content: SwiftUI.View>: View {
    
    @ViewBuilder var left: () -> Content
    @ViewBuilder var right: () -> Content
    
    @ViewBuilder
    var body: some View {
        HStack {
            left()
            Spacer()
            right()
                .foregroundStyle(.secondary)
        }
    }
}
