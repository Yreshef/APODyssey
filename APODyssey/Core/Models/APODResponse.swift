//
//  AstronomyPicture.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

struct APODResponse: Decodable, Identifiable, Hashable {
    var id: String { date }  //Only one image per day, each date is unique

    let date: String
    let title: String
    let explanation: String
    let url: String?
    let hdurl: String?
    let mediaType: String
    let copyright: String?
    
    enum CodingKeys: String, CodingKey {
        case date
        case title
        case explanation
        case url
        case hdurl
        case mediaType = "media_type"
        case copyright
    }
}
