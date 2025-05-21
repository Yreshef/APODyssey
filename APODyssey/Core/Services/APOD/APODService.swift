//
//  APODService.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Combine
import Foundation

protocol APODServicing {
    func fetch(for date: Date) async throws -> PictureOfTheDay
    func fetchRange(from startDate: Date, to endDate: Date) async throws
        -> [PictureOfTheDay]
}

final class APODService: APODServicing {

    private let networkService: NetworkServicing
    private let decoder: JSONDecoder
    private let hasher1: ImageURLHashing
    private let hasher2: ImageURLHashing
    
    private let supportedMediaType: String = "image"

    init(
        networkService: NetworkServicing, decoder: JSONDecoder = JSONDecoder(),
        hasher1: ImageURLHashing, hasher2: ImageURLHashing
    ) {
        self.networkService = networkService
        self.decoder = decoder
        self.hasher1 = hasher1
        self.hasher2 = hasher2
    }

    func fetch(for date: Date) async throws -> PictureOfTheDay {
        let raw = try await networkService.fetch(from: .apod(route: .date(date)))
        let response = try decoder.decode(APODResponse.self, from: raw)
        
        guard response.mediaType == supportedMediaType else {
            throw APODError.mapping(.unsupportedMediaType(type: response.mediaType))
        }
        
        guard let urlString = response.url,
              let imageURL = URL(string: urlString),
              let hdurlString = response.hdurl
        else {
            throw APODError.network(.invalidURL)
        }
        let hdURL = response.hdurl.flatMap(URL.init)

        let urlData = Data(urlString.utf8)
        let hdURLData = Data(hdurlString.utf8)
        let h1 = hasher1.hash(data: urlData)
        let h2 = hasher2.hash(data: urlData)
        let h3 = hasher1.hash(data: hdURLData)

        return PictureOfTheDay(
            date: response.date,
            title: response.title,
            explanation: response.explanation,
            copyright: response.copyright,
            imageURL: imageURL,
            hdImageURL: hdURL,
            hash1: h1,
            hash2: h2,
            hdHash: h3)
    }

    func fetchRange(from startDate: Date, to endDate: Date) async throws-> [PictureOfTheDay]{
        let raw = try await networkService.fetch(
            from: .apod(route: .dateRange(start: startDate, end: endDate)))
        let responses = try decoder.decode([APODResponse].self, from: raw)
        return try responses
            .filter { $0.mediaType == supportedMediaType }
            .map { resp in
            guard let urlString = resp.url,
                  let imageURL = URL(string: urlString),
                  let hdurlString = resp.hdurl
            else {
                throw APODError.network(.noData)
            }
            let hdURL = resp.hdurl.flatMap(URL.init)
            
            let urlData = Data(urlString.utf8)
            let hdURLData = Data(hdurlString.utf8)
            let h1 = hasher1.hash(data: urlData)
            let h2 = hasher2.hash(data: urlData)
            let h3 = hasher1.hash(data: hdURLData)

            return PictureOfTheDay(
                date: resp.date,
                title: resp.title,
                explanation: resp.explanation,
                copyright: resp.copyright,
                imageURL: imageURL,
                hdImageURL: hdURL,
                hash1: h1,
                hash2: h2,
                hdHash: h3
            )
        }
    }
}
