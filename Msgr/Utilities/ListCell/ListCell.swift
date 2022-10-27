//
//  ListCell.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 26/8/22.
//

import SwiftUI

struct ListCell: View {
    
    let data: ListCellData

    var body: some View {
        content
    }

    private var content: some View {
        HStack {
            if let icon = data.icon {
                XIcon(icon)
                    .foregroundColor(.accentColor)
            }
            Text(data.title)
            if let subtitle = data.subTitle {
                Spacer()
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
