//
//  BackgroundTappable.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/11/22.
//

import SwiftUI

struct TapToRouteModifier: ViewModifier {

    let route: NavigationRouter.Route
    @EnvironmentObject private var viewRouter: NavigationRouter
    
    func body(content: Content) -> some View {
        content
            .backgroundTapped {
                viewRouter.routes.appendUnique(route)
            }
    }
}

struct BackgroundTappable: ViewModifier {

    let action: () -> Void
    func body(content: Content) -> some View {
        content
            .onTapGesture(perform: action)
            .background {
                Button(action: action) {
                    Color.clear
                }
                .buttonStyle(.borderless)
            }
    }
}

extension View {
    func backgroundTapped(_ action: @escaping () -> Void) -> some View {
        ModifiedContent(content: self, modifier: BackgroundTappable(action: action))
    }
    func tapToRoute(_ route: NavigationRouter.Route) -> some View {
        ModifiedContent(content: self, modifier: TapToRouteModifier(route: route))
    }
}
