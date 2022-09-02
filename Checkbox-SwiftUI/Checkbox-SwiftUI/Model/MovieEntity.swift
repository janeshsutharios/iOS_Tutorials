//
//  Movie.swift
//
//  Created by JaneshSwift.com
//

import Foundation
import UIKit


class MoviesModel: ObservableObject {
    @Published var data: [MovieEntity] = []
    init() {
        self.data = MockDataJSON.movies
    }
}

struct MovieEntity {
    let title: String
    var isFavorite = false
}

extension MovieEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case title
    }
}
