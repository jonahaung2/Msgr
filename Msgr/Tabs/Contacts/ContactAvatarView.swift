//
//  ContactAvatarView.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/11/22.
//

import SwiftUI

struct ContactAvatarView: View {
    let id: String
    let urlString: String

    @State private var image: UIImage?
    let size: CGFloat
    var body: some View {
        ZStack {
            let url = self.url
            let image = self.image ?? UIImage(contentsOfFile: url.path)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Image(systemName: XIcon.Icon.person_crop_circle.systemName)
                    .resizable()
                    .scaledToFit()
                    .task {
                        if let image = await downloadImageFrom(urlString: urlString, localPath: url.path) {
                            self.image = image
                        }
                    }
            }
        }
        .frame(width: size, height: size)
    }

    private func downloadImageFrom(urlString: String?, localPath: String) async -> UIImage? {
        guard let urlString, let url = URL(string: urlString) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)?.resized(to: .init(width: 75, height: 75))
            image?.jpegData(compressionQuality: 1)?.write(path: localPath)
            return image
        } catch {
            print(error)
            return nil
        }
    }

    private var url: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("\(self.id).jpg")
        if !FileManager.default.fileExists(atPath: path.absoluteString) {
            try? FileManager.default.createDirectory(atPath: path.absoluteString, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }
}


extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        defer {
            UIGraphicsEndImageContext()
        }
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
            CGSize(
                width: size.width * widthRatio,
                height: size.height * widthRatio
            )
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
extension UIImage {
    static let circleImage: UIImage = {
        let size: CGSize = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        let circleImage = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.red.cgColor)

            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        return circleImage
    }()
}

extension UIImage {
    func tinted(with fillColor: UIColor) -> UIImage? {
        let image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        fillColor.set()
        image.draw(in: CGRect(origin: .zero, size: size))

        guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()
        return imageColored
    }
}

extension UIImage {
    func temporaryLocalFileUrl() throws -> URL? {
        guard let imageData = jpegData(compressionQuality: 1.0) else { return nil }
        let imageName = "\(UUID().uuidString).jpg"
        let documentDirectory = NSTemporaryDirectory()
        let localPath = documentDirectory.appending(imageName)
        let photoURL = URL(fileURLWithPath: localPath)
        try imageData.write(to: photoURL)
        return photoURL
    }
}
