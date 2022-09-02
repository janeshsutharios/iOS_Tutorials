//
//  Checkbox_SwiftUIApp.swift
//  Checkbox-SwiftUI
//
//  Created by JaneshSwift.com on 02/09/22.
//

import SwiftUI

@main
struct Checkbox_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
           ContentView()
        }
    }
}

struct ContentView: View {
    @State var movies: [MovieEntity] = MockDataJSON.movies
    var body: some View {
        MoviesListView()
    }
}
