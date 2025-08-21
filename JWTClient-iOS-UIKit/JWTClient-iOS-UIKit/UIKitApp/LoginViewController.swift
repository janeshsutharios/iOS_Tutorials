import UIKit

final class LoginViewController: UIViewController {
    private let auth: AuthService
    var onSuccess: (() -> Void)?

    private let stack = UIStackView()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)

    init(auth: AuthService) {
        self.auth = auth
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.text = "test"
        
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.text = "password"
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        statusLabel.textColor = .secondaryLabel
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.numberOfLines = 0

        spinner.hidesWhenStopped = true

        [usernameField, passwordField, loginButton, spinner, statusLabel].forEach { stack.addArrangedSubview($0) }
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func loginTapped() {
        view.endEditing(true)
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        guard !username.isEmpty, !password.isEmpty else {
            statusLabel.text = "Please enter username and password"
            return
        }
        loginButton.isEnabled = false
        statusLabel.text = "Logging in…"
        spinner.startAnimating()

        auth.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.spinner.stopAnimating()
                self.loginButton.isEnabled = true
                switch result {
                case .success:
                    self.statusLabel.text = "Login success"
                    self.dismiss(animated: true) { self.onSuccess?() }
                case .failure(let error):
                    self.statusLabel.text = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}


