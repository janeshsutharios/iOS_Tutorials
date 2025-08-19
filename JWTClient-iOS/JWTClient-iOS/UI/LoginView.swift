import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    @Published var username: String = "test"
    @Published var password: String = "password"
    @Published var error: AppError? = nil
    @Published var isLoading: Bool = false
    
    var isValidUsername: Bool { username.count >= 3 }
    var isValidPassword: Bool { password.count >= 4 }
    
    func validate() -> Bool {
        if !isValidUsername { error = .custom("Username must be at least 3 characters."); return false }
        if !isValidPassword { error = .custom("Password must be at least 4 characters."); return false }
        error = nil
        return true
    }
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var vm = LoginViewModel()
    @FocusState private var focused: Field?
    enum Field { case username, password }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome").font(.largeTitle).bold()
            
            TextField("Username", text: $vm.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: .username)
                .submitLabel(.next)
                .onSubmit { focused = .password }
            
            SecureField("Password", text: $vm.password)
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: .password)
                .submitLabel(.go)
                .onSubmit { login() }
            
            if let error = vm.error {
                Text(error.message).foregroundColor(.red)
            }
            
            Button {
                login()
            } label: {
                if vm.isLoading { ProgressView() } else { Text("Login").bold() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isLoading || !vm.isValidUsername || !vm.isValidPassword)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Login")
    }
    
    private func login() {
        guard vm.validate() else { return }
        vm.isLoading = true
        Task {
            defer { vm.isLoading = false }
            do {
                try await auth.login(username: vm.username, password: vm.password)
            } catch {
                vm.error = error as? AppError
            }
        }
    }
}
