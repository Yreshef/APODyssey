//
//  NetworkService.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation
import Combine

protocol NetworkServicing {
    func fetch(from route: NetworkRoute) -> AnyPublisher<Data, NetworkError>
    func fetchImageData(from url: URL) -> AnyPublisher<Data, NetworkError>
}

final class NetworkService: NetworkServicing {
    
    let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetch(from route: NetworkRoute) -> AnyPublisher<Data, NetworkError> {
        
        guard var components = URLComponents(string: route.urlPath) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = route.parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else {
            return Fail(error: NetworkError.failedToBuildURLFromComponents).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = route.method
        request.timeoutInterval = 10
        
        for (headerField, value) in route.headers {
            request.setValue(value, forHTTPHeaderField: headerField)
        }
        
        return urlSession
            .dataTaskPublisher(for: request)
            .tryMap { response -> Data in
                
                guard let res = response.response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard 200...299 ~= res.statusCode else {
                    throw NetworkError.requestFailure(statusCode: res.statusCode)
                }
                
                return response.data
            }
            .mapError { error -> NetworkError in
                if let netError = error as? NetworkError {
                    return netError
                } else {
                    return .unknown(error: error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchImageData(from url: URL) -> AnyPublisher<Data, NetworkError> {
        urlSession.dataTaskPublisher(for: url)
            .tryMap { response in
                guard let res = response.response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard 200...299 ~= res.statusCode else {
                    throw NetworkError.requestFailure(statusCode: res.statusCode)
                }
                
                return response.data
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return .unknown(error: error)
                }
            }
            .eraseToAnyPublisher()
    }
}
