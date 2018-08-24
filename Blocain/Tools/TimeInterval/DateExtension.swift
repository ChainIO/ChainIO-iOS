//
//  DateExtension.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/23.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import Foundation

extension Date {
    static func convertUTCTimeToElapsedTime(utcTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = dateFormatter.date(from: utcTime) {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.maximumUnitCount = 1
            if let elapsedString = formatter.string(from: date, to: Date()) {
                let modifiedString = elapsedString.replacingOccurrences(of: "minutes", with: "min")
                return modifiedString + " ago"
            }
        }
        return ""
    }
}
