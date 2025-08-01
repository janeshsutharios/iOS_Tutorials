import SwiftUI
import Combine

// MARK: - ViewModel with Leaky Timer
final class TimerViewModel: ObservableObject {
    @Published var count: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            // To reproduce issue remove weak self here, you will observer timer still runs on background & deinit never get called.
            .sink { [weak self] _ in
                self?.count += 1
                print("⏱️ Timer fired: \(self?.count ?? 0)")
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("🧹 TimerViewModel deallocated")
    }
}

// MARK: - SwiftUI View
struct LeakyTimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Timer count: \(viewModel.count)")
                .font(.largeTitle)
            Button("Dismiss") {
                dismiss()
            }
        }
        .padding()
    }
}

// MARK: - Entry Point View
struct MemoryLeakExamples: View {
    @State private var showLeak = false
    
    var body: some View {
        VStack {
            Button("Show Leaky Timer View") {
                showLeak = true
            }
        }
        .sheet(isPresented: $showLeak) {
            LeakyTimerView()
        }
    }
}
