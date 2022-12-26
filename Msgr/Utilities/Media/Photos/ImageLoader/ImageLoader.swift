//
//  ImageData.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 09/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import SwiftUI
import Combine

class ImageLoaderCache {
    
    static let shared = ImageLoaderCache()
    
    private var loaders: NSCache<NSString, ImageLoader> = NSCache()

    func loaderFor(url: URL) -> ImageLoader {
        let key = NSString(string: url.absoluteString)
        if let loader = loaders.object(forKey: key) {
            return loader
        } else {
            let loader = ImageLoader(url: url)
            loaders.setObject(loader, forKey: key)
            return loader
        }
    }
}



final class ImageLoader: ObservableObject {

    private let url: URL
    @Published var image: UIImage?
    
    var objectWillChange: AnyPublisher<UIImage?, Never> = Publishers.Sequence<[UIImage?], Never>(sequence: []).eraseToAnyPublisher()
    private var cancellable: AnyCancellable?
    
    init(url: URL) {
        self.url = url
        objectWillChange = $image.handleEvents(receiveSubscription: { _ in
            self.loadImage()
        }, receiveCancel: {
            self.cancellable?.cancel()
        }).eraseToAnyPublisher()
    }
    
    private func loadImage() {
        guard image == nil else { return }
        cancellable = fetchImage(url)
            .receive(on: DispatchQueue.main)
            .assign(to: \ImageLoader.image, on: self)
    }

    func fetchImage(_ url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> UIImage? in
                    return UIImage(data: data)
                }.catch { _ in
                    return Just(nil)
                }
                .eraseToAnyPublisher()
        }
    deinit {
        cancellable?.cancel()
    }
    
}
