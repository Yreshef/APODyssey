//
//  Environment.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation

enum Environment {
  static var nasaApiKey: String {
    guard let key = ProcessInfo.processInfo.environment["NASA_API_KEY"], !key.isEmpty else {
      fatalError("Missing NASA_API_KEY…")
    }
    return key
  }
}
