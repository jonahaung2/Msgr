//
//  Reloadable.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 4/9/22.
//

import SwiftUI

public struct ReloadModifier: ViewModifier {
    let reload: () async -> ()
//    @EnvironmentObject private var reloader: Reloader
    public func body(content: Content) -> some View {
        content
//            .onChange(of: reloader.reload) { _ in
//                Task {
//                    await reload()
//                }
//            }
    }
}

public extension View {
    func reloadable(_ reload: @escaping () async -> ()) -> some View {
        ModifiedContent(content: self, modifier: ReloadModifier(reload: reload))
    }
}

