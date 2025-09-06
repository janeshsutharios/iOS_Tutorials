//
//  ComposeView.swift
//  Messages
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine

public struct ComposeView: View {
    @StateObject private var viewModel = ComposeViewModel()
    @EnvironmentObject private var router: MessagesRouter
    @State private var recipientId: String = ""
    @State private var messageContent: String = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("To:")
                        .font(.headline)
                    
                    TextField("Enter user ID", text: $recipientId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message:")
                        .font(.headline)
                    
                    TextEditor(text: $messageContent)
                        .frame(minHeight: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                Button("Send Message") {
                    viewModel.sendMessage(to: recipientId, content: messageContent)
                }
                .buttonStyle(.borderedProminent)
                .disabled(recipientId.isEmpty || messageContent.isEmpty || viewModel.isSending)
                .frame(maxWidth: .infinity)
                
                if viewModel.isSending {
                    ProgressView("Sending...")
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if viewModel.messageSent {
                    Text("Message sent successfully!")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .padding()
            .navigationTitle("Compose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        router.navigateBack()
                    }
                }
            }
        }
        .onReceive(viewModel.$messageSent) { sent in
            if sent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    router.navigateBack()
                }
            }
        }
    }
}

// MARK: - Compose ViewModel
@MainActor
public final class ComposeViewModel: ObservableObject {
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    @Published var messageSent: Bool = false
    
    private let messagesService: MessagesServiceProtocol
    
    public init(messagesService: MessagesServiceProtocol = MockMessagesService()) {
        self.messagesService = messagesService
    }
    
    public func sendMessage(to userId: String, content: String) {
        guard !userId.isEmpty && !content.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isSending = true
        errorMessage = nil
        messageSent = false
        
        Task {
            do {
                let success = try await messagesService.sendMessage(to: userId, content: content)
                if success {
                    messageSent = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }
}
