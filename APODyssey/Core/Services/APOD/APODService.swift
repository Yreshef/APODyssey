//
//  APODService.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

protocol APODServicing {
    
}

final class APODService: APODServicing {
    
    private var networkService: NetworkServicing
    
    init(networkService: NetworkServicing) {
        self.networkService = networkService
    }
}
