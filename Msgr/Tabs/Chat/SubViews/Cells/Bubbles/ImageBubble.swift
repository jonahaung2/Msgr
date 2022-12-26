//
//  ImageBubble.swift
//  Conversation
//
//  Created by Aung Ko Min on 31/1/22.
//

import SwiftUI


struct ImageBubble: View {
    
    @EnvironmentObject internal var msg: Msg

    var body: some View {
        ImageView(.msgs((msg.conId, msg.id)), .original, urlString: "https://i.pinimg.com/474x/77/c9/09/77c9094d787c29d3c0b7e2d77c080ba5.jpg") {
            ProgressView()
        }
        .scaledToFit()
    }
}
