//
//  APODError.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

enum APODError: Error {
    case network(NetworkError)
    case decoding(DecodingError)
    case unknown(Error)
}
