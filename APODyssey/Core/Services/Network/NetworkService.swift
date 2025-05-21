//
//  NetworkService.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import Foundation

protocol NetworkServicing {
    func fetch(from route: NetworkRoute) async throws -> Data
    func fetchImage(from url: URL) async throws -> Data
}

final class NetworkService: NetworkServicing {
    let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetch(from route: NetworkRoute) async throws -> Data {
        guard var components = URLComponents(string: route.urlPath) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = route.parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        guard let url = components.url else {
            throw NetworkError.failedToBuildURLFromComponents
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = route.method
        request.timeoutInterval = 10
        
        for (headerField, value) in route.headers {
            request.setValue(value, forHTTPHeaderField: headerField)
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailure(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    func fetchImage(from url: URL) async throws -> Data {
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailure(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
}
