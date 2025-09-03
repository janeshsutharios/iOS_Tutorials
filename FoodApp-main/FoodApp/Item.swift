//
//  Item.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
