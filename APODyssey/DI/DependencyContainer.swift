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
    
    private var networkService: NetworkServicing
    var apodService: APODServicing
    
    init(networkService: NetworkServicing = NetworkService()) {
        self.networkService = networkService
        self.apodService = APODService(networkService: self.networkService)
    }
}
