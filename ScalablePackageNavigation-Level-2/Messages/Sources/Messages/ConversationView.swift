//
//  ConversationView.swift
//  Messages
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine


public struct ConversationView: View {
    let userId: String
    @StateObject private var viewModel: ConversationViewModel
    @EnvironmentObject private var router: MessagesRouter
    @State private var messageText: String = ""
    
    public init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: ConversationViewModel(userId: userId))
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading conversation...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Messages List
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.messages, id: \.id) { message in
                                    MessageBubble(message: message, isFromCurrentUser: message.senderId == "user-1")
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Message Input
                    HStack {
                        TextField("Type a message...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Send") {
                            viewModel.sendMessage(content: messageText)
                            messageText = ""
                        }
                        .disabled(messageText.isEmpty || viewModel.isSending)
                    }
                    .padding()
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
            }
            .navigationTitle("User \(userId)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        router.navigateBack()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadConversation()
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - Conversation ViewModel

@MainActor
public final class ConversationViewModel: ObservableObject {
    let userId: String
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    
    private let messagesService: MessagesServiceProtocol
    
    public init(userId: String, messagesService: MessagesServiceProtocol = MockMessagesService()) {
        self.userId = userId
        self.messagesService = messagesService
    }
    
    public func loadConversation() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let messages = try await messagesService.fetchConversation(id: userId)
                self.messages = messages
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    public func sendMessage(content: String) {
        guard !content.isEmpty else { return }
        
        isSending = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await messagesService.sendMessage(to: userId, content: content)
                if success {
                    // Reload conversation to show new message
                    await loadConversation()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }
}
