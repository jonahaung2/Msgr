//
//  PhotoDownload.swift
//  Msgr
//
//  Created by Aung Ko Min on 11/12/22.
//

import SwiftUI
enum ImageSize {

    case small, medium, large, extraLarge
    case custom(CGFloat)

    var width: CGFloat {
        switch self {
        case .small: return 25
        case .medium: return 55
        case .large: return 120
        case .extraLarge: return 250
        case .custom(let x): return x }
    }

    var description: String {
        switch self {
        case .small:
            return "small"
        case .medium:
            return "medium"
        case .large:
            return "large"
        case .extraLarge:
            return "extraLarge"
        case .custom(let cGFloat):
            return cGFloat.description
        }
    }
}

struct ImageView<Placeholder>: View where Placeholder: View {

    @State private var image: Image?
    @State private var task: Task<(), Never>?
    @State private var isProgressing = false

    private let photoKind: LocalMedia.MediaKind.PhotoKind
    private let photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize

    private let urlString: String?
    private let placeholder: () -> Placeholder?

    init(_ photoKind: LocalMedia.MediaKind.PhotoKind, _ photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize, urlString: String?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.photoKind = photoKind
        self.photoSize = photoSize
        self.urlString = urlString
        self.placeholder = placeholder
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                placholderView
                imageView
                progressView
            }
            .frame(size: proxy.size)
            .task {
                loadImage()
            }
            .onDisappear {
                task?.cancel()
            }
        }
    }

    private func loadImage() {
        task?.cancel()
        guard let urlString, !urlString.isWhitespace else {
            image = nil
            return
        }
        guard image == nil else { return }

        task = Task.detached(priority: .background) {
            await MainActor.run {
                isProgressing = true
            }
            do {
                let image = try await ImageManager.shared.loadImage(photoKind: photoKind, photoSize: photoSize, urlString: urlString)
                await MainActor.run {
                    isProgressing = false
                    self.image = Image(uiImage: image)
                }
            } catch {
                await MainActor.run {
                    Log(error)
                    isProgressing = false
                }
            }
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let image {
            image
                .resizable()
                .scaledToFill()
        }
    }

    @ViewBuilder
    private var placholderView: some View {
        if !isProgressing, image == nil {
            placeholder()
        }
    }

    @ViewBuilder
    private var progressView: some View {
        if isProgressing {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}

enum ImageError: Error{
    case ThumbnilFailed
}


final class ImageManager {

    static let shared = ImageManager()
    private let queue = DispatchQueue(label: "ImageDataManagerQueue")

    private lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 90
        configuration.timeoutIntervalForRequest     = 90
        configuration.timeoutIntervalForResource    = 90
        return URLSession(configuration: configuration)
    }()

    private init() {}

    func loadImage(photoKind: LocalMedia.MediaKind.PhotoKind, photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize, urlString: String?) async throws -> UIImage {

        guard let urlString, let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        if let localImage = UIImage(contentsOfFile: photoKind.path(for: photoSize)) {
            return localImage
        }
        return try await downloadImage(photoKind, photoSize, url)
    }

    //URL.init(string:"https://www.apple.com/v/home/hc/images/overview/ios15_logo__cnpdxsz7otzm_large_2x.png")!)
    private func downloadImage(_ photoKind: LocalMedia.MediaKind.PhotoKind, _ photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize, _ url: URL) async throws -> UIImage {

        let (data, _) = try await downloadSession.data(from: url)

        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }

        guard let thumbnilImage = await image.byPreparingThumbnail(ofSize: .init(size: 100)) else {
            throw ImageError.ThumbnilFailed
        }

        queue.async {
            if let data = image.jpegData(compressionQuality: 1) {
                LocalMedia.save(data, at: photoKind.path(for: .original), encrypt: false)
            }
            if let data = thumbnilImage.jpegData(compressionQuality: 1) {
                LocalMedia.save(data, at: photoKind.path(for: .thumbnil), encrypt: false)
            }
        }
        return photoSize == .thumbnil ? thumbnilImage : image
    }
}


class ImageService {
    class func resize(_ image: UIImage, to width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth

        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        let newSize = CGSize(width: newWidth, height: newHeight)

        return UIGraphicsImageRenderer(size: newSize).image { _ in
            image.draw(in: .init(origin: .zero, size: newSize))
        }
    }
}
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
