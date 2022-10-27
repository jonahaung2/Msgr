//
//  NavigationLinkStyle.swift
//  MyBike
//
//  Created by Aung Ko Min on 28/11/21.
//

import SwiftUI

public struct TapToPushStyle<Destination: View>: ViewModifier {
    
    let destination: Destination
    
    public func body(content: Content) -> some View {
        NavigationLink(destination: destination) {
            content
        }
    }
}

public extension View {
    func tapToPush<Destination: View>(_ destination: Destination) -> some View {
        ModifiedContent(content: self, modifier: TapToPushStyle(destination: destination))
    }
}
