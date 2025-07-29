// Some tips before starts
Prefer Value Types (Structs) When Possible
Value types are copied when passed around, reducing the risk of shared mutable state.

// MARK: Example 1 
class HomeViewControllerLegacy {

    private var loadingView = UIView() // Error here `Main actor-isolated default value in a nonisolated context`
    var hasLaunched = false
    
    @MainActor
     func home() {
        self.hasLaunched = true
    }
}

// To solve it - initializing the view at declaration time, so you can safely create it in viewDidLoad() which runs on the main thread.
class HomeViewControllerNew: UIViewController {
    private var loadingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = UIView()
        loadingView.backgroundColor = .gray
        view.addSubview(loadingView)
    }
}

// MARK: Example 2 Passing closure as a 'sending' parameter risks causing data races 
class LoggerLegacy {
    var logs: [String] = []

    func log(_ message: String) {
        logs.append(message)
    }
}
struct WorkerLegacy {
    let logger: Logger

    func doWork() {
        Task {//<<-- Error Passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure
            logger.log("Work started") 
        }
    }
}

//-> If you know there is no data race in your codebase & want to skip data race use @preconcurrency
@preconcurrency
class LoggerNew {
    var logs: [String] = []

    func log(_ message: String) {
        logs.append(message)
    }
}

extension LoggerNew: @unchecked Sendable {}

struct WorkerNew {
    let logger: LoggerNew

    func doWork() {
        Task {
            logger.log("Work started") // ✅ No error now
        }
    }
}

// MARK: Example # Trying to access heightConstraint from background thread.

class ProfileViewControllerLegacy: UIViewController {
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

// Solution ->
class ProfileViewControllerNew: UIViewController {
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

// MARK: Example #4 UI Updates from Background Threads
class CartView {
    
    @IBOutlet var label: UILabel!

     // Error version
    func addItemLegacy() {
        DispatchQueue.global().async {
            // Error here # Main actor-isolated property 'text' can not be mutated from a Sendable closure
            self.label.text = "Updated"
        }
    }

     // Fix version
    func addItemFixed() {
        Task { @MainActor in
            self.label.text = "Updated"
        }
    }

}

// MARK: Example #5 Accessing Non-Sendable Types Across Threads
class SongClassLegacy {
    var data: String = ""
    
    func update() {
        DispatchQueue.global().async {
            // Warning here Capture of 'self' with non-sendable type 'SongClass' in a '@Sendable' closure
            // Warning Class 'SongClass' does not conform to the 'Sendable' protocol
            self.data.append("New")
        }
    }
}

actor SongClassNew {
    private var data = ""

    func append(_ value: String) {
        data.append(value)
    }

    func getData() -> String {
        return data
    }
}

// MARK: Example #6 sendable examples
final class SteelFactoryLegacy {
    // Closure to be called after background work
    var onUpdate: (() -> Void)?
    
    func performWork() {
        DispatchQueue.global().async { [weak self] in
            // Simulate background work
            sleep(1)
            // Warning Capture of 'self' with non-sendable type 'SteelFactoryLegacy?' in a '@Sendable' closure
            self?.onUpdate?()
            
        }
    }
}


final class SteelFactoryNew {
    // Closure that can be safely called from concurrent contexts
    var onUpdate: (@Sendable () -> Void)?

    func performWork() {
        DispatchQueue.global().async { [onUpdate] in
            // Simulate background work
            sleep(1)

            // Safely call the closure
            onUpdate?()
        }
    }
}
// Usage -
class CompanyOffice {
    
    func getInfo() {
        let manager = SteelFactoryNew()
        manager.onUpdate = { [message = "Update received!"] in
            print(message)
        }
        manager.performWork()

    }
}

