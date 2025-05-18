//
//  DependencyContainer.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

protocol DependencyProviding {
    var apodService: APODServicing { get }
}

final class DependencyContainer: DependencyProviding {
    
    private let networkService: NetworkServicing
    var apodService: APODServicing
    var imageService: ImageServicing
    
    init(networkService: NetworkServicing = NetworkService()) {
        self.networkService = networkService
        self.apodService = APODService(networkService: self.networkService)
        self.imageService = ImageService(networkService: networkService,
                                         hasher1: SHA256ImageHasher(), //Hash1 = SHA-256
                                         hasher2: MD5ImageHashing()) //Hash2 = MD5
    }
}
