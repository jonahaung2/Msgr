//
//  XListStyle.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 3/9/22.
//

import SwiftUI

enum XListStyle: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case Inset_Grouped, Group, Inset, Plain, Default
}

extension View {
    @ViewBuilder
    func xListStyle(type: XListStyle) -> some View {
        switch type {
        case .Inset_Grouped:
            self.listStyle(.insetGrouped)
        case .Group:
            self.listStyle(.grouped)
        case .Inset:
            self.listStyle(.inset)
        case .Plain:
            self.listStyle(.plain)
        case .Default:
            self.listStyle(.automatic)
        }
    }
}
