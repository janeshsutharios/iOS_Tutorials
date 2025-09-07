//
//  InboxView.swift
//  Messages
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine


public struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()
    @EnvironmentObject private var router: MessagesRouter
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading messages...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No Messages")
                            .font(.headline)
                        
                        Text("You don't have any messages yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Compose Message") {
                            router.navigate(to: .compose)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.messages, id: \.id) { message in
                        MessageRow(message: message) {
                            router.navigate(to: .conversation(message.senderId))
                        }
                    }
                    .refreshable {
                        viewModel.loadMessages()
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Compose") {
                        router.navigate(to: .compose)
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Button("Search") {
                        router.navigate(to: .search)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadMessages()
        }
    }
}

// MARK: - Message Row

struct MessageRow: View {
    let message: Message
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(message.senderId.prefix(1)).uppercased())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                // Message Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("User \(message.senderId)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(message.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Inbox ViewModel

@MainActor
public final class InboxViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let messagesService: MessagesServiceProtocol
    
    public init(messagesService: MessagesServiceProtocol = MockMessagesService()) {
        self.messagesService = messagesService
    }
    
    public func loadMessages() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let messages = try await messagesService.fetchInbox()
                self.messages = messages
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
