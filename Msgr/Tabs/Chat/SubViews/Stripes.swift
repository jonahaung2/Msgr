//
//  Stripes.swift
//  Msgr
//
//  Created by Aung Ko Min on 5/11/22.
//

import SwiftUI

public struct StripesConfig {
    var background: Color
    var foreground: Color
    var degrees: Double
    var barWidth: CGFloat
    var barSpacing: CGFloat

    public init(background: Color = Color.pink.opacity(0.5), foreground: Color = Color.pink.opacity(0.8),
                degrees: Double = 30, barWidth: CGFloat = 20, barSpacing: CGFloat = 20) {
        self.background = background
        self.foreground = foreground
        self.degrees = degrees
        self.barWidth = barWidth
        self.barSpacing = barSpacing
    }

    public static let `default` = StripesConfig()
}


public struct Stripes: View {
    var config: StripesConfig

    public init(config: StripesConfig) {
        self.config = config
    }

    public var body: some View {
        GeometryReader { geometry in
            let longSide = max(geometry.size.width, geometry.size.height)
            let itemWidth = config.barWidth + config.barSpacing
            let items = Int(2 * longSide / itemWidth)
            HStack(spacing: config.barSpacing) {
                ForEach(0..<items) { index in
                    config.foreground
                        .frame(width: config.barWidth, height: 2 * longSide)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotationEffect(Angle(degrees: config.degrees), anchor: .center)
            .offset(x: -longSide / 2, y: -longSide / 2)
            .background(config.background)
        }
        .clipped()
    }
}

public struct Squares: View {
    var configA: StripesConfig
    var configB: StripesConfig

    public init(config: StripesConfig) {
        configA = config
        configB = config
        configB.degrees = config.degrees - 90
    }

    public var body: some View {
        ZStack {
            Stripes(config: configA)
            Stripes(config: configB)
        }
    }
}
