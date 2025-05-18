//
//  FetchedImage.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

struct FetchedImage {
    let image: UIImage
    let hash1: String
    let hash2: String
    
    // Optional: generated from 300x300 resize
    let thumbnail300: UIImage?
    let thumbnailHash: String?
}
