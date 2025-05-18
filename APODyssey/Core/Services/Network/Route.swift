//
//  Route.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

protocol Route {
    var urlPath: String { get }
    var parameters: [String: String] { get }
    
    var method: String { get }
    var headers: [String: String] { get }
}

enum NetworkRoute: Route {
    
    case apod(route: APODRoute)

    var urlPath: String {
        switch self {
        case .apod(let route): return route.urlPath
        }
    }
    var parameters: [String : String] {
        switch self {
        case .apod(let route): return route.parameters
        }
    }
}

//Future proofing default implementation
extension Route {
    var method: String { "GET" }
    var headers: [String: String] { [:] }
}
