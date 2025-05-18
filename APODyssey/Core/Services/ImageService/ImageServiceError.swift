//
//  ImageServiceError.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

enum ImageServiceError: Error {
    case network(NetworkError)
    case invalidImageData
}
