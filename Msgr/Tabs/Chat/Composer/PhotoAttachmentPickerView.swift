//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

struct PhotoAttachmentPickerView: View {
    
    @StateObject var assetLoader = PhotoAssetLoader()

    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    private var assets: PHFetchResultCollection
    
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 2)]

    init(onImageTap: @escaping (AddedAsset) -> Void, imageSelected: @escaping (String) -> Bool) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        self.assets = .init(fetchResult: fetchResult)
        self.onImageTap = onImageTap
        self.imageSelected = imageSelected
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(assets) { asset in
                    PhotoAttachmentCell(assetLoader: assetLoader, asset: asset, onImageTap: onImageTap, imageSelected: imageSelected)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

/// Photo cell displayed in the picker view.
public struct PhotoAttachmentCell: View {
    
    @StateObject var assetLoader: PhotoAssetLoader
    @State private var assetURL: URL?
    @State private var compressing = false
    @State private var loading = false
    @State var requestId: PHContentEditingInputRequestID?
    
    var asset: PHAsset
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    
    private var assetType: AssetType {
        asset.mediaType == .video ? .video : .image
    }
    
    public var body: some View {
        ZStack {
            if let image = assetLoader.loadedImages[asset.localIdentifier] {
                GeometryReader { reader in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: reader.size.width, height: reader.size.height)
                            .allowsHitTesting(false)
                            .clipped()
                        
                        // Needed because of SwiftUI bug with tap area of Image.
                        Button {
                            if let assetURL {
                                onImageTap(AddedAsset(image: image, id: asset.localIdentifier, url: assetURL, type: assetType, extraData: asset.mediaType == .video ? ["duration": asset.durationString] : [:]))
                            }
                        } label: {
                            Color.clear
                                .frame(width: reader.size.width, height: reader.size.height)
                                .allowsHitTesting(true)
                        }
                    }
                    .overlay((compressing || loading) ? ProgressView() : nil)

                }
            } else {
                Color.yellow
                    .aspectRatio(1, contentMode: .fill)

            }
        }
        .aspectRatio(1, contentMode: .fill)
        .overlay(
            ZStack {
                if imageSelected(asset.localIdentifier) {
                    TopRightView {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.white)
                    }
                }
                
                if asset.mediaType == .video {
                    VideoIndicatorView()
                    VideoDurationIndicatorView(
                        duration: asset.durationString
                    )
                }
            }
        )
        .task {
            assetLoader.loadImage(from: asset)
            if self.assetURL != nil {
                return
            }
            
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            self.loading = true
            
            self.requestId = asset.requestContentEditingInput(with: options) { input, _ in
                self.loading = false
                if asset.mediaType == .image {
                    self.assetURL = input?.fullSizeImageURL
                } else if let url = (input?.audiovisualAsset as? AVURLAsset)?.url {
                    self.assetURL = url
                }
                
                // Check file size.
                if let assetURL = assetURL{
                    compressing = true
                    assetLoader.compressAsset(at: assetURL, type: assetType) { url in
                        self.assetURL = url
                        self.compressing = false
                    }
                }
            }
        }
        .onDisappear() {
            if let requestId = requestId {
                asset.cancelContentEditingInputRequest(requestId)
                self.requestId = nil
            }
        }
    }
}

/// View container that allows injecting another view in its top right corner.
public struct TopRightView<Content: View>: View {
    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            VStack {
                content()
                Spacer()
            }
        }
    }
}
