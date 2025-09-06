//
//  NavigationPath+Extensions.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI

// MARK: - NavigationPath Extensions
public extension NavigationPath {
    /// Safely removes the last item from the navigation path
    mutating func safeRemoveLast() {
        if !isEmpty {
            removeLast()
        }
    }
    
    /// Removes all items from the navigation path
    mutating func removeAll() {
        while !isEmpty {
            removeLast()
        }
    }
    
    /// Returns the current depth of the navigation stack
    var depth: Int {
        return count
    }
}
