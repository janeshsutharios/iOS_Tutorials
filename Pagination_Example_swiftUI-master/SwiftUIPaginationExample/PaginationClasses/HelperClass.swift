//
//  HelperClass.swift
//  InfiniteListSwiftUI
//
//  Created by Janesh on 17/08/21.


import UIKit
import Foundation
import SwiftUI

// MARK: - GitHelper

struct GitResponseEntity: Codable {
    var totalCount: Int?
    var incompleteResults: Bool?
    var items: [Item]?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

// MARK: - Item
struct Item: Codable,Identifiable {
    var id: Int?
    var  name, fullName: String?
    var node_id:String
    //var uniqueId = UUID()
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case name
        case node_id
        
    }
}



extension RandomAccessCollection where Self.Element: Identifiable {
    public func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = firstIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        let distance = self.distance(from: itemIndex, to: endIndex)
        return distance == 1
    }
    
    public func isThresholdItem<Item: Identifiable>(offset: Int,
                                                    item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = firstIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        let offset = offset < count ? offset : count - 1
        return offset == (distance - 1)
    }
}
extension String: Identifiable {
    public var id: String {
        return self
    }
}



struct Spinner: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: style)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return spinner
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}
