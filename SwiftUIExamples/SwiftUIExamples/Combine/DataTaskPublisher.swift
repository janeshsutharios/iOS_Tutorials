//
//  DataTaskPublisher.swift
//  SwiftUIExamples
//
//  Created by Janesh Suthar-M2 on 09/07/25.
//
import SwiftUI
import Combine

// MARK: - Model
struct Post: Decodable, Identifiable {
    let id: Int
    let title: String
}

// MARK: - ViewModel
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)// ✅ Publisher
            .map(\.data) // 🔁 Operator
            .decode(type: [Post].self, decoder: JSONDecoder()) // 🔁 Operator
            .receive(on: DispatchQueue.main) // 🔁 Operator
            .sink { completion in // ✅ Subscriber
                // Handle failure
                if case let .failure(error) = completion {
                    self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                }
            } receiveValue: { posts in
                self.posts = posts
            }
            .store(in: &cancellables)
    }
    /* Or you can just use below for plain data handling<No errors handling>
     .map(\.data)
     .decode(type: [Post].self, decoder: JSONDecoder())
     .replaceError(with: [])
     .receive(on: DispatchQueue.main)
     .assign(to: \.posts, on: self)
     .store(in: &cancellables)
     */
}

// MARK: - View
struct PostListView: View {
    @StateObject private var viewModel = PostViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    // 🔴 Show error message if any
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                List(viewModel.posts) { post in
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Posts")
            .onAppear {
                viewModel.fetchPosts()
            }
        }
    }
}
#Preview {
    PostListView()
}
