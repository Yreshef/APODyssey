//
//  ImageHashing.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import CryptoKit
import Foundation

protocol ImageHashing {
    func hash(data: Data) -> String
}

struct MD5ImageHashing: ImageHashing {
    func hash(data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

struct SHA256ImageHasher: ImageHashing {
    func hash(data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
