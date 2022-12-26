//
//  ChatInputBar.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ChatInputBar: View {

    @EnvironmentObject private var viewModel: ChatViewModel
    @State private var text = ""
    @State private var showPhotoAttachmentPicker = false
    @State private var assets = [AddedAsset]()

    var body: some View {
        VStack(spacing: 0) {
            if assets.isEmpty == false {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(assets) { asset in
                            Image(uiImage: asset.image)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(height: 120)
                    .animation(.default, value: assets)
                }
                Divider()
            }
            HStack(alignment: .bottom) {
                Button {
                    withAnimation(.easeIn(duration: 0.2)) {
                        showPhotoAttachmentPicker.toggle()
                    }
                } label: {
                    Image(systemName: "camera.macro")
                        .resizable()
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.tint, .background)
                        .frame(width: 25, height: 25)
                        .padding(5)
                }

                TextField("Text..", text: $text, axis: .vertical)
                    .lineLimit(1...10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background (
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(uiColor: .separator), lineWidth: 1)
                    )
                    .onChange(of: text.isEmpty) { isEmpty in
                        viewModel.conversation.setTyping(isTyping: !isEmpty)
                    }

                Button(action: action) {
                    ZStack {
                        if text.isEmpty {
                            Image(systemName: "hand.thumbsup.fill")
                                .resizable()
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.tint, .background)
                        } else {
                            Image(systemName: "chevron.up.circle.fill")
                                .resizable()
                        }
                    }
                    .frame(width: 30, height: 30)
                    .padding(5)
                    .transition(.scale(scale: 0.1).animation(.interactiveSpring()))
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal)

            if showPhotoAttachmentPicker {
                attachmentPicker
            }
        }
        .background(.thickMaterial)
    }

    private func action() {
        if text.isWhitespace {
            text = Lorem.random
            return
        }
        let sendText = text
        text.removeAll()
        MsgSender.shared.send(.Text(text: sendText), con: viewModel.conversation.con)
    }

    @ViewBuilder
    private var attachmentPicker: some View {
        VStack {
            HStack {
                Image(systemName: XIcon.Icon.pin_fill.systemName)
                    .tapToPresent(FilePickerView(fileURLs: .constant([])).presentationDetents([.medium, .large]))

                Image(systemName: "camera.macro")
                    .tapToPresent(ImagePickerView(sourceType: .photoLibrary, onAssetPicked: { item in
                        DispatchQueue.main.async {
                            self.assets.append(item)
                        }
                    }).presentationDetents([.medium, .large]))
            }
            .imageScale(.large)
            .foregroundStyle(Color.accentColor)

            PhotoAttachmentPickerView { asset in
                if self.assets.contains(asset) {
                    self.assets.removeAll { x in
                        x == asset
                    }
                } else {
                    self.assets.append(asset)
                }
            } imageSelected: { selected in
                assets.filter{ $0.id == selected }.count > 0
            }
            .frame(height: UIScreen.main.bounds.height/2.5)
        }
        .transition(.move(edge: .bottom))
    }
}
