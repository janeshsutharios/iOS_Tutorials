//
//  Row.swift
//  Created by JaneshSwift.com


import SwiftUI

struct ListItemCell: View {
    
    @ObservedObject var movie:MoviesModel
    var currentIndex:Int = 0
    var body: some View {
        HStack {
            Button(action: { self.movie.data[currentIndex].isFavorite.toggle() }) {
                CheckBoxView(isChecked: movie.data[currentIndex].isFavorite)
            }
            Text(movie.data[currentIndex].title)
            Spacer()
        }
    }
}

struct ListItemCell_Previews: PreviewProvider {
    static var previews: some View {
        ListItemCell(movie: MoviesModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
