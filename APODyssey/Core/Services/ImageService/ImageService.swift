//
//  ImageService.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit
import Combine

protocol ImageServicing {
    func fetchImage(from url: URL) -> AnyPublisher<FetchedImage, ImageServiceError>
}

final class ImageService: ImageServicing {
    
    private let networkService: NetworkServicing
    private let hasher1: ImageHashing
    private let hasher2: ImageHashing
    
    init(networkService: NetworkServicing, hasher1: ImageHashing, hasher2: ImageHashing) {
        self.networkService = networkService
        self.hasher1 = hasher1
        self.hasher2 = hasher2
    }
    
    func fetchImage(from url: URL) -> AnyPublisher<FetchedImage, ImageServiceError> {
        networkService.fetchImageData(from: url)
            .mapError { ImageServiceError.network($0) }
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw ImageServiceError.invalidImageData
                }
                                                            
                let hash1 = self.hasher1.hash(data: data)
                let hash2 = self.hasher2.hash(data: data)
                
                let thumbnail300 = image.resized(to: CGSize(width: 300, height: 300))
                let thumbnailHash = thumbnail300?.hash(using: self.hasher2)

                return FetchedImage(image: image,
                                    hash1: hash1,
                                    hash2: hash2,
                                    thumbnail300: thumbnail300,
                                    thumbnailHash: thumbnailHash)
            }
            .mapError { error in
                error as? ImageServiceError ?? .invalidImageData
            }
            .eraseToAnyPublisher()
    }
}
