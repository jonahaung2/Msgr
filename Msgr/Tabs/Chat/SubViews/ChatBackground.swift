//
//  ChatBackground.swift
//  Msgr
//
//  Created by Aung Ko Min on 5/11/22.
//

import SwiftUI

struct ChatBackground: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    var testReduceTransparency = false
    var body: some View {
        if reduceTransparency || testReduceTransparency {
            LinearNonTransparency()
        } else {
            FloatingClouds()
        }
    }
}

struct LinearNonTransparency: View {
    @Environment(\.colorScheme) var scheme
    var gradient: Gradient {
        Gradient(colors: [Theme.ellipsesTopLeading(forScheme: scheme), Theme.ellipsesTopTrailing(forScheme: scheme)])
    }

    var body: some View {
        LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
struct Theme {

    static var generalBackground: Color {
        return Color.sectionBackground
    }

    static func ellipsesTopLeading(forScheme scheme: ColorScheme) -> Color {
        return .background
    }

    static func ellipsesTopTrailing(forScheme scheme: ColorScheme) -> Color {
        return .accentColor
    }
    static func ellipsesBottomTrailing(forScheme scheme: ColorScheme) -> Color {
        return .background
    }

    static func ellipsesBottomLeading(forScheme scheme: ColorScheme) -> Color {
        return .background
    }
}
class CloudProvider: ObservableObject {

    let offset: CGSize
    let frameHeightRatio: CGFloat

    init() {
        frameHeightRatio = CGFloat.random(in: 0.7 ..< 1.4)
        offset = CGSize(width: CGFloat.random(in: -150 ..< 150),
                        height: CGFloat.random(in: -150 ..< 150))
    }
}

struct Cloud: View {

    @StateObject var provider = CloudProvider()
    @State var move = false
    let proxy: GeometryProxy
    let color: Color
    let rotationStart: Double
    let duration: Double
    let alignment: Alignment

    var body: some View {
        Circle()
            .fill(color)
            .frame(height: proxy.size.height /  provider.frameHeightRatio)
            .offset(provider.offset)
            .rotationEffect(.init(degrees: move ? rotationStart : rotationStart + 360) )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .opacity(0.8)
            .onAppear {
                withOptionalAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    move.toggle()
                }
            }
    }

    func withOptionalAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
        if UIAccessibility.isReduceMotionEnabled {
            return try body()
        } else {
            return try withAnimation(animation, body)
        }
    }
}

struct FloatingClouds: View {

    @Environment(\.colorScheme) var scheme
    let blur: CGFloat = 60

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Theme.generalBackground
                ZStack {
                    Cloud(proxy: proxy,
                          color: Theme.ellipsesBottomTrailing(forScheme: scheme),
                          rotationStart: 0,
                          duration: 60,
                          alignment: .bottomTrailing)
                    Cloud(proxy: proxy,
                          color: .accentColor,
                          rotationStart: 240,
                          duration: 50,
                          alignment: .topTrailing)
                    Cloud(proxy: proxy,
                          color: Theme.ellipsesBottomLeading(forScheme: scheme),
                          rotationStart: 120,
                          duration: 80,
                          alignment: .bottomLeading)
                    Cloud(proxy: proxy,
                          color: Theme.ellipsesTopLeading(forScheme: scheme),
                          rotationStart: 180,
                          duration: 70,
                          alignment: .topLeading)
                }
                .blur(radius: blur)
            }
            //            .ignoresSafeArea()
        }
    }
}
