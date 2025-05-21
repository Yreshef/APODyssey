//
//  APODError.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

enum APODError: LocalizedError {
    case network(NetworkError)
    case decoding(DecodingError)
    case mapping(PictureMappingError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .decoding(let error):
            return error.localizedDescription
        case .mapping(let error):
            return error.localizedDescription
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

enum PictureMappingError: LocalizedError {
    case incompleteResponse(date: String)
    case unsupportedMediaType(type: String)

    var errorDescription: String? {
        switch self {
        case .incompleteResponse(let date):
            return "Missing image data for APOD on \(date)."
        case .unsupportedMediaType(let type):
            return "Unsupported media type received: \(type)."
        }
    }
}
