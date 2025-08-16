//
//  File.swift
//  JWTClient-iOS
//
//  Created by Janesh Suthar on 16/08/25.
//

import Foundation

extension Date {
    /// Formats the date into a human-readable string 
    func toGSTString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}
