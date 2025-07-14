import SwiftUI
import Combine

class ButtonThrottleViewModel: ObservableObject {
    let buttonTapSubject = PassthroughSubject<Void, Never>()
    @Published var message = "Tap the button"
    
    var cancellables = Set<AnyCancellable>()

    init() {
        buttonTapSubject
            .throttle(for: .seconds(2), scheduler: RunLoop.main, latest: false)
            .sink { [weak self] in
                let timeString = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                self?.message = "🚨 Action executed at \(timeString)"
                print("🚨 Button action executed")
            }
            .store(in: &cancellables)
    }
}

struct ButtonThrottle: View {

    @StateObject var viewModel = ButtonThrottleViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.message)
                .padding()
            
            Button("Submit") {
                viewModel.buttonTapSubject.send()
            }
        }
        .padding()
    }
}

#Preview {
    ButtonThrottle()
}
