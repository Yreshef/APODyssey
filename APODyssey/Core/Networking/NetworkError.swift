//
//  NetworkError.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case failedToBuildURLFromComponents
    case invalidResponse
    case requestFailure(statusCode: Int)
    case decodingFailure
    case noData
    case unknown(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to build URL from provided route."
        case .failedToBuildURLFromComponents:
            return "Failed to construct URLRequest."
        case .invalidResponse:
            return "The server response was not an HTTP response."
        case .requestFailure(let statusCode):
            return "Request failed with status code \(statusCode)."
        case .decodingFailure:
            return "Failed to decode response."
        case .noData:
            return "Request returned no data."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
