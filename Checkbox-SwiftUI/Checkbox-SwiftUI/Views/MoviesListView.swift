//  Created by JaneshSwift.com

import SwiftUI

struct MoviesListView: View {
    @StateObject var movies = MoviesModel()
    var body: some View {
        VStack {
            List {
                ForEach(Array(movies.data.enumerated()), id: \.offset) { index, element in
                    ListItemCell(movie: movies, currentIndex: index)
                }
            }
            Button {
                print("Selected values ----->", movies.data.filter{$0.isFavorite})
            } label: {
                Text("Get Selected Values")
            }
        }
        .navigationBarTitle("All Movies")
    }
}

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoviesListView()
        }
    }
}
