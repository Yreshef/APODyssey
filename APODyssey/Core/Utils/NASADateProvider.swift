//
//  NASADateProvider.swift
//  APODyssey
//
//  Created by Yohai on 20/05/2025.
//

import Foundation

struct NASADateProvider {
    /// Returns today's date in NASA’s expected UTC format: midnight, no time component.
    static var today: Date {
        let calendar = Calendar(identifier: .gregorian)
        var utc = calendar
        utc.timeZone = TimeZone(secondsFromGMT: 0)!

        let components = utc.dateComponents([.year, .month, .day], from: Date())
        return utc.date(from: components)!
    }
}
