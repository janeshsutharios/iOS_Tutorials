//
//  TestData.swift
//
//  Created by JaneshSwift.com
//

import Foundation
struct MockDataJSON {
    static var movies: [MovieEntity] = {
        let url = Bundle.main.url(forResource: "Movies", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try! decoder.decode([MovieEntity].self, from: data)
    }()
}
