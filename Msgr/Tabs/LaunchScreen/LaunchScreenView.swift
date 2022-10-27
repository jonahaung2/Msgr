//
//  LaunchScreenView.swift
//  Msgr
//
//  Created by Aung Ko Min on 28/10/22.
//

import SwiftUI

struct LaunchScreenView: View {

    @State private var move = true
    @State private var swinging = true

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            ZStack {
                Image(systemName: "message.badge.filled.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.secondary)
                    .scaleEffect(0.6)
                    .rotationEffect(
                        .degrees(swinging ? -10 : 10),
                        anchor: swinging ? .bottomLeading : .bottomTrailing
                    )
                    .offset(y: -15)
                    .animation(.easeInOut(duration: 1).repeatCount(14, autoreverses: true), value: swinging)
                VStack(spacing: -46) {
                    Image("stream_wave")
                        .offset(y: 20)
                        .offset(x: move ? -160 : 160)
                        .animation(.linear(duration: 14), value: move)
                    Image("stream_wave")
                        .offset(y: 10)
                        .offset(x: move ? -150 : 150)
                        .animation(.linear(duration: 14), value: move)
                        .onAppear {
                            move.toggle()
                            swinging.toggle()
                        }
                }
                .mask(Image("wave_top"))
            }
            // Change size here
            .scaleEffect(2)
        }
    }
}
