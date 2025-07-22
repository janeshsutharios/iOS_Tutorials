// MARK: Example 1 
/*class HomeViewController {

     private var loadingView = UIView() // Error here `Main actor-isolated default value in a nonisolated context`

    var hasLaunched = false
    
    @MainActor
     func home() {
        self.hasLaunched = true
    }
}
*/
// To solve it - initializing the view at declaration time, so you can safely create it in viewDidLoad() which runs on the main thread.

class HomeViewController: UIViewController {
    private var loadingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = UIView()
        loadingView.backgroundColor = .gray
        view.addSubview(loadingView)
    }
}

// MARK: Example 2 Passing closure as a 'sending' parameter risks causing data races 
/*
class Logger {
    var logs: [String] = []

    func log(_ message: String) {
        logs.append(message)
    }
}
struct Worker {
    let logger: Logger

    func doWork() {
        Task {//<<-- Error Passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure
            logger.log("Work started") 
        }
    }
}
*/
//-> If you know there is no data race in your codebase & want to skip data race use @preconcurrency
@preconcurrency
class Logger {
    var logs: [String] = []

    func log(_ message: String) {
        logs.append(message)
    }
}

extension Logger: @unchecked Sendable {}

struct Worker {
    let logger: Logger

    func doWork() {
        Task {
            logger.log("Work started") // ✅ No error now
        }
    }
}

// Example #3 Trying to access heightConstraint from background thread.
/*
class ProfileViewController: UIViewController {
    var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global().async {
            // ❌ This is a background thread!
            // ❌ Call to main actor-isolated instance method 'constraint(equalToConstant:)' in a synchronous nonisolated context
            self.heightConstraint = self.view.heightAnchor.constraint(equalToConstant: 0)
            self.heightConstraint.isActive = true
        }
    }
}
*/
// Solution ->
class ProfileViewController: UIViewController {
    var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Simulate background work
        DispatchQueue.global().async {
            // ✅ Launch a Swift concurrency task from background by using MainActor
            Task { @MainActor in
                self.heightConstraint = self.view.heightAnchor.constraint(equalToConstant: 0)
                self.heightConstraint.isActive = true
            }
        }
    }
}





