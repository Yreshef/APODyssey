//
//  DependencyContainer.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

protocol DependencyProviding {
    var pictureRepository: PictureRepository { get }
}

final class DependencyContainer: DependencyProviding {
    
    private let networkService: NetworkServicing
    private let apodService: APODServicing
    private let imageService: ImageServicing
    let pictureRepository: PictureRepository
    
    init(networkService: NetworkServicing = NetworkService()) {
        self.networkService = networkService
        self.apodService = APODService(networkService: networkService, hasher1: SHA256ImageURLHasher(), hasher2: MD5ImageURLHashing())
        self.imageService = ImageService(networkService: networkService)
        self.pictureRepository = APODRepository(service: apodService, imageService: imageService)
    }
}
