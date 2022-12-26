//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View used to indicate that an asset is a video.
public struct VideoIndicatorView: View {


    public init() {}

    public var body: some View {
        BottomLeftView {
            Image(systemName: "video.fill")
                .customizable()
                .frame(width: 22)
                .padding(2)


        }
    }
}

/// View displaying the duration of the video.
public struct VideoDurationIndicatorView: View {

    var duration: String

    public init(duration: String) {
        self.duration = duration
    }

    public var body: some View {
        BottomRightView {
            Text(duration)
                .bold()
                .padding(.all, 4)

        }
    }
}

/// Container that displays attachment types.
public struct AttachmentTypeContainer<Content: View>: View {
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Color.red
                .frame(height: 20)
            
            content()
                .background()
        }
        .background()
        .cornerRadius(16)
        .accessibilityIdentifier("AttachmentTypeContainer")
    }
}

/// View shown after the native file picker is closed.
struct FilePickerDisplayView: View {

    
    @Binding var filePickerShown: Bool
    @Binding var addedFileURLs: [URL]
    
    var body: some View {
        AttachmentTypeContainer {
            ZStack {
                Button {
                    filePickerShown = true
                } label: {
                    Text("FilePickerDisplayView")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $filePickerShown) {
                FilePickerView(fileURLs: $addedFileURLs)
            }
        }
    }
}

/// View displayed when the camera picker is shown.
struct CameraPickerDisplayView: View {
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var cameraPickerShown: Bool
    
    var cameraImageAdded: (AddedAsset) -> Void
    
    var body: some View {
        Spacer()
            .fullScreenCover(isPresented: $cameraPickerShown, onDismiss: {
                selectedPickerState = .photos
            }) {
                ImagePickerView(sourceType: .camera) { addedImage in
                    cameraImageAdded(addedImage)
                }
                .edgesIgnoringSafeArea(.all)
            }
    }
}


/// View container that allows injecting another view in its bottom right corner.
public struct BottomRightView<Content: View>: View {
    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                content()
            }
        }
    }
}

/// View container that allows injecting another view in its bottom left corner.
public struct BottomLeftView<Content: View>: View {
    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            VStack {
                Spacer()
                content()
            }
            Spacer()
        }
    }
}

extension Image {
    public func customizable() -> some View {
        renderingMode(.template)
            .resizable()
            .scaledToFit()
    }
}
public struct DiscardButtonView: View {

    var color = Color.black.opacity(0.8)

    public init(color: Color = Color.black.opacity(0.8)) {
        self.color = color
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)

            Image(systemName: "xmark.circle.fill")
                .renderingMode(.template)
                .foregroundColor(color)
        }
        .padding(.all, 4)
    }
}
