//
//  PictureOfTheDay.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

struct PictureOfTheDay: Identifiable {
    var id: String { date }

    let date: String
    let title: String
    let explanation: String
    let copyright: String?
    let imageURL: URL
    let hdImageURL: URL?
    let hash1: String
    let hash2: String
    let hdHash: String
}
