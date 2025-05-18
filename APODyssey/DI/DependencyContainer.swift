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
        self.apodService = APODService(networkService: self.networkService)
        self.imageService = ImageService(networkService: networkService,
                                         hasher1: SHA256ImageHasher(), //Hash1 = SHA-256
                                         hasher2: MD5ImageHashing()) //Hash2 = MD5
        self.pictureRepository = APODRepository(apodService: apodService, imageService: imageService)
    }
}
