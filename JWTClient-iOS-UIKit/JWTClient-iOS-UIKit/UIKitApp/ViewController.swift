import UIKit

final class ViewController: UIViewController {
    private let container = AppContainer.make()
    private let concurrentManager = DashboardConcurrentQueueManager()
    private let sequentialManager = DashboardSequentialQueueManager()

    private let stack = UIStackView()
    private let headerStack = UIStackView()
    private let dashboardStack = UIStackView()

    private let titleLabel = UILabel()
    private let modeControl = UISegmentedControl(items: ["⚡️ Async", "🔄 Sync"])
    private let logoutButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // Section cards
    private let profileCard = UIView()
    private let restaurantsCard = UIView()
    private let festivalsCard = UIView()
    private let usersCard = UIView()

    private let profileTitle = UILabel()
    private let restaurantsTitle = UILabel()
    private let festivalsTitle = UILabel()
    private let usersTitle = UILabel()

    private let profileContent = UIStackView()
    private let restaurantsContent = UIStackView()
    private let festivalsContent = UIStackView()
    private let usersContent = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "JWTClient UIKit"
        setupUI()
        // Auto-fetch on dashboard load
        runSequential()
    }

    private func setupUI() {
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        // Header (Dashboard title + Logout)
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12

        titleLabel.text = "Dashboard"
        titleLabel.font = .systemFont(ofSize: 44, weight: .bold)
        titleLabel.numberOfLines = 1

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.backgroundColor = .systemBackground
        logoutButton.layer.cornerRadius = 22
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(spacer)
        headerStack.addArrangedSubview(logoutButton)

        // Segmented control for mode
        modeControl.selectedSegmentIndex = 0
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        modeControl.backgroundColor = .tertiarySystemFill
        modeControl.selectedSegmentTintColor = .systemBackground
        loadingIndicator.hidesWhenStopped = true

        // Dashboard cards
        dashboardStack.axis = .vertical
        dashboardStack.spacing = 12

        [profileCard, restaurantsCard, festivalsCard, usersCard].forEach { card in
            card.backgroundColor = .secondarySystemBackground
            card.layer.cornerRadius = 16
        }

        [profileTitle, restaurantsTitle, festivalsTitle, usersTitle].forEach { label in
            label.font = .systemFont(ofSize: 26, weight: .bold)
        }
        profileTitle.text = "Profile"
        restaurantsTitle.text = "Restaurants"
        festivalsTitle.text = "Festivals"
        usersTitle.text = "Users"

        [profileContent, restaurantsContent, festivalsContent, usersContent].forEach { s in
            s.axis = .vertical
            s.spacing = 6
            s.translatesAutoresizingMaskIntoConstraints = false
        }

        func composeCard(_ container: UIView, title: UILabel, content: UIStackView) {
            let v = UIStackView()
            v.axis = .vertical
            v.spacing = 8
            v.translatesAutoresizingMaskIntoConstraints = false
            v.isLayoutMarginsRelativeArrangement = true
            v.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            v.addArrangedSubview(title)
            v.addArrangedSubview(content)
            container.addSubview(v)
            NSLayoutConstraint.activate([
                v.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                v.topAnchor.constraint(equalTo: container.topAnchor),
                v.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }

        composeCard(profileCard, title: profileTitle, content: profileContent)
        composeCard(restaurantsCard, title: restaurantsTitle, content: restaurantsContent)
        composeCard(festivalsCard, title: festivalsTitle, content: festivalsContent)
        composeCard(usersCard, title: usersTitle, content: usersContent)

        // Assemble root layout
        view.addSubview(stack)
        stack.addArrangedSubview(headerStack)
        let modeContainer = UIStackView(arrangedSubviews: [modeControl, loadingIndicator])
        modeContainer.axis = .horizontal
        modeContainer.alignment = .center
        modeContainer.spacing = 8
        stack.addArrangedSubview(modeContainer)
        stack.addArrangedSubview(dashboardStack)

        [profileCard, restaurantsCard, festivalsCard, usersCard].forEach { dashboardStack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    @objc private func modeChanged() {
        switch modeControl.selectedSegmentIndex {
        case 0: runConcurrent()
        default: runSequential()
        }
    }

    @objc private func runConcurrent() {
        setLoading(true)
        renderMessage("Running async fetch…")
        concurrentManager.fetchDashboard(api: container.api, auth: container.authService) { [weak self] dashboard in
            self?.setLoading(false)
            self?.render(dashboard)
        }
    }

    @objc private func runSequential() {
        setLoading(true)
        renderMessage("Running sync fetch…")
        sequentialManager.fetchDashboard(api: container.api, auth: container.authService) { [weak self] dashboard in
            self?.setLoading(false)
            self?.render(dashboard)
        }
    }

    @objc private func logoutTapped() {
        container.authService.logout()
        // Switch back to login on logout
        let loginVC = LoginViewController(auth: container.authService)
        loginVC.onSuccess = { [weak self] in
            let dashboardVC = ViewController()
            self?.view.window?.rootViewController = dashboardVC
        }
        present(loginVC, animated: true)
    }

    private func setLoading(_ loading: Bool) {
        // Keep the mode control interactive as requested
        logoutButton.isEnabled = !loading
        if loading { loadingIndicator.startAnimating() } else { loadingIndicator.stopAnimating() }
    }

    private func render(_ data: DashboardData) {
        clearContents()
        if let profile = data.profile {
            profileContent.addArrangedSubview(makeValueLabel("Username: \(profile.username)"))
            profileContent.addArrangedSubview(makeValueLabel("Role: \(profile.role)"))
        } else {
            profileContent.addArrangedSubview(makeValueLabel("Profile: nil"))
        }

        if let restaurants = data.restaurants, !restaurants.isEmpty {
            restaurants.forEach { restaurantsContent.addArrangedSubview(makeValueLabel($0.name)) }
        } else {
            restaurantsContent.addArrangedSubview(makeValueLabel("No restaurants"))
        }

        if let festivals = data.festivals, !festivals.isEmpty {
            festivals.forEach { festivalsContent.addArrangedSubview(makeValueLabel($0.name)) }
        } else {
            festivalsContent.addArrangedSubview(makeValueLabel("No festivals"))
        }

        if let users = data.users, !users.isEmpty {
            users.forEach { usersContent.addArrangedSubview(makeValueLabel($0.username)) }
        } else {
            usersContent.addArrangedSubview(makeValueLabel("No users"))
        }
    }

    private func renderMessage(_ message: String) {
        clearContents()
        profileContent.addArrangedSubview(makeValueLabel(message))
    }

    private func clearContents() {
        [profileContent, restaurantsContent, festivalsContent, usersContent].forEach { s in
            s.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
    }

    private func makeValueLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 20, weight: .regular)
        return l
    }
}

