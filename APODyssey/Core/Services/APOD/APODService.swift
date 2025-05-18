//
//  APODService.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Combine
import Foundation

protocol APODServicing {
    func fetchToday() -> AnyPublisher<APODResponse, APODError>
    func fetch(date: Date) -> AnyPublisher<APODResponse, APODError>
    func fetchRange(start: Date, end: Date) -> AnyPublisher<
        [APODResponse], APODError
    >
}

final class APODService: APODServicing {

    private let networkService: NetworkServicing
    private let decoder: JSONDecoder

    init(networkService: NetworkServicing, decoder: JSONDecoder = .init()) {
        self.networkService = networkService
        self.decoder = decoder
    }

    func fetchToday() -> AnyPublisher<APODResponse, APODError> {
        return fetch(date: Date())
    }

    func fetch(date: Date) -> AnyPublisher<APODResponse, APODError> {
        networkService.fetch(from: .apod(route: .date(date)))
            .decode(type: APODResponse.self, decoder: decoder)
            .handleEvents(receiveOutput: { _ in
                print("Fetched APOD for date: \(date)")
            })
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return APODError.decoding(decodingError)
                } else if let networkError = error as? NetworkError {
                    return .network(networkError)
                } else {
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchRange(start: Date, end: Date) -> AnyPublisher<
        [APODResponse], APODError
    > {
        networkService.fetch(
            from: .apod(route: .dateRange(start: start, end: end))
        )
        .decode(type: [APODResponse].self, decoder: decoder)
        .handleEvents(receiveOutput: { pictures in
            print("📅 APOD fetched range: \(start) to \(end)")
            print("✅ Received \(pictures.count) pictures")
        })
        .mapError { error in
            if let decodingError = error as? DecodingError {
                return APODError.decoding(decodingError)
            } else if let networkError = error as? NetworkError {
                return .network(networkError)
            } else {
                return .unknown(error)
            }
        }
        .eraseToAnyPublisher()
    }
}
