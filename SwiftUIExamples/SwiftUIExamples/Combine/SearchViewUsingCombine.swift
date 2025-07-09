//
//  CombineExamples.swift
//  SwiftUIExamples
//
//  Created by Janesh Suthar on 09/07/25.
//

import SwiftUI
import Combine

// MARK: - ViewModel
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [String] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main) // Delay to reduce search frequency
            .removeDuplicates() // Avoid firing same queries repeatedly
            .sink { [weak self] text in
                self?.search(text)
            }
            .store(in: &cancellables) // ✅ Keeps the Combine pipeline alive as long as the ViewModel lives other wise you will not able to recieve events. try commenting out & see results.
    }

    private func search(_ query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }

        // Simulated network search logic
        results = (1...5).map { "Result \($0) for '\(query)'" }
    }
}

// MARK: - View
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Search Text Field
                TextField("Search...", text: $viewModel.searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Results List
                List(viewModel.results, id: \.self) { result in
                    Text(result)
                }
            }
            .navigationTitle("Search Example")
        }
    }
}
