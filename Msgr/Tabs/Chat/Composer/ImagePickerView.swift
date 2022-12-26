//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import AVFoundation
import SwiftUI

/// Image picker for loading images.
struct ImagePickerView: UIViewControllerRepresentable {

    @Environment(\.dismiss) var dismiss
    let sourceType: UIImagePickerController.SourceType
    var onAssetPicked: (AddedAsset) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            pickerController.sourceType = sourceType
        }
        pickerController.mediaTypes = ["public.image", "public.movie"]
        
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> ImagePickerCoordinator {
        Coordinator(self)
    }
}

final class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var parent: ImagePickerView

    init(_ control: ImagePickerView) {
        parent = control
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let id = UUID().uuidString
        if let uiImage = info[.originalImage] as? UIImage, let imageURL = try? uiImage.temporaryLocalFileUrl(id: id) {
            let addedImage = AddedAsset(image: uiImage, id: id, url: imageURL, type: .image)
            parent.onAssetPicked(addedImage)
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            do {
                let asset = AVURLAsset(url: videoURL, options: nil)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imageGenerator.copyCGImage(
                    at: CMTimeMake(value: 0, timescale: 1),
                    actualTime: nil
                )
                let thumbnail = UIImage(cgImage: cgImage)
                let addedVideo = AddedAsset( image: thumbnail, id: id, url: videoURL, type: .video)
                parent.onAssetPicked(addedVideo)
            } catch {
                Log(error)
            }
        }
        dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }

    private func dismiss() {
        parent.dismiss()
    }
}

extension UIImage {
    func temporaryLocalFileUrl(id: String) throws -> URL? {
        guard let imageData = jpegData(compressionQuality: 1.0) else { return nil }
        let localPath = File.temp(id: id, ext: "jpeg")
        imageData.write(path: localPath)
        return URL(fileURLWithPath: localPath)
    }
}
