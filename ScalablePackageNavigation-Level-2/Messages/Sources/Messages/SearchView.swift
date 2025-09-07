//
//  SearchView.swift
//  Messages
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine


public struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var router: MessagesRouter
    @State private var searchQuery: String = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search messages...", text: $searchQuery)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            viewModel.searchMessages(query: searchQuery)
                        }
                    
                    if !searchQuery.isEmpty {
                        Button("Clear") {
                            searchQuery = ""
                            viewModel.clearSearch()
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Search Results
                if viewModel.isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty && !searchQuery.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No Results")
                            .font(.headline)
                        
                        Text("No messages found for '\(searchQuery)'")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("Search Messages")
                            .font(.headline)
                        
                        Text("Enter a search term to find messages")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.searchResults, id: \.id) { message in
                        SearchResultRow(message: message) {
                            router.navigate(to: .conversation(message.senderId))
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        router.navigateBack()
                    }
                }
            }
        }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let message: Message
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("User \(message.senderId)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(message.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search ViewModel

@MainActor
public final class SearchViewModel: ObservableObject {
    @Published var searchResults: [Message] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    
    private let messagesService: MessagesServiceProtocol
    
    public init(messagesService: MessagesServiceProtocol = MockMessagesService()) {
        self.messagesService = messagesService
    }
    
    public func searchMessages(query: String) {
        guard !query.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        
        Task {
            do {
                let messages = try await messagesService.searchMessages(query: query)
                searchResults = messages
            } catch {
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }
    
    public func clearSearch() {
        searchResults = []
        errorMessage = nil
    }
}
