//
//  APODRoute.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

enum APODRoute: Route {
    
    case today
    case date(Date)
    case dateRange(start: Date, end: Date)
    case random(count: Int)
    
    private var apiKey: String {
        return Environment.nasaApiKey
    }
    
    var urlPath: String {
        return "https://api.nasa.gov/planetary/apod"
    }
    
    var parameters: [String : String] {
        var params: [String : String] = ["api_key" : apiKey]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        switch self {
        case .today: break
        case .date(let date): params["date"] = formatter.string(from: date)
        case .dateRange(let start, let end):
            params["start_date"] = formatter.string(from: start)
            params["end_date"] = formatter.string(from: end)
        case .random(let count): params["count"] = "\(count)"
        }
        
        return params
    }
}
