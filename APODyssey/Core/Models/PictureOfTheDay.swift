//
//  PictureOfTheDay.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

struct PictureOfTheDay: Identifiable {
    var id: String { date }

    // Raw APOD metadata
    let date: String
    let title: String
    let explanation: String
    let copyright: String?
    let imageURL: URL
    let hdImageURL: URL?

    // Image rendering
    let image: UIImage
    let hash1: String
    let hash2: String

    // Thumbnails
    let thumbnail100: UIImage?
    let thumbnail300: UIImage?
    let thumbnail300Hash: String?
}
