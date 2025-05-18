//
//  AstronomyPicture.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

struct AstronomyPicture: Decodable {
    let date: String
    let explanation: String
    let hdurl: String?
    let media_type: String
    let service_version: String
    let title: String
    let url: String
    let thumbnail_url: String?
    let copyright: String?
}
