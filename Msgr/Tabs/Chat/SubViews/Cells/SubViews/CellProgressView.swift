//
//  CellProgressView.swift
//  Conversation
//
//  Created by Aung Ko Min on 17/2/22.
//

import SwiftUI

struct CellProgressView: View {
    
    let progress: Msg.DeliveryStatus

    @ViewBuilder
    var body: some View {
        if let iconName = progress.iconName() {
            Image(systemName: iconName)
                .imageScale(.small)
                .foregroundStyle(.tertiary)
        }
    }
}
