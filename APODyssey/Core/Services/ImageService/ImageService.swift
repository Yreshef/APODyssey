//
//  ImageService.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

enum ImageServiceError: Error {
    case networkError(Error)
    case invalidData
}

protocol ImageServicing {
    func fetchImageData(from url: URL) async throws -> Data
}

final class ImageService: ImageServicing {
    
    private let networkService: NetworkServicing
    private var cache = NSCache<NSURL, NSData>()
    
    init(networkService: NetworkServicing) {
        self.networkService = networkService
    }
    
    func fetchImageData(from url: URL) async throws -> Data {
        let key = url as NSURL
        
        if let cached = cache.object(forKey: key) {
            return  cached as Data
        }
        let data: Data
        do {
            data = try await networkService.fetchImage(from: url)
        } catch {
            throw ImageServiceError.networkError(error)
        }
        guard !data.isEmpty else {
            throw ImageServiceError.invalidData
        }
        
        cache.setObject(data as NSData, forKey: key)
        return data
    }
}
