import Foundation

// Generic asynchronous Operation base class with proper KVO compliance
// Allows us to wrap async/await work inside OperationQueue flows
class AsynchronousOperation: Operation {
    private let stateQueue = DispatchQueue(label: "AsynchronousOperation.state")

    private var _isExecuting: Bool = false
    override private(set) var isExecuting: Bool {
        get { stateQueue.sync { _isExecuting } }
        set {
            willChangeValue(forKey: "isExecuting")
            stateQueue.sync { _isExecuting = newValue }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get { stateQueue.sync { _isFinished } }
        set {
            willChangeValue(forKey: "isFinished")
            stateQueue.sync { _isFinished = newValue }
            didChangeValue(forKey: "isFinished")
        }
    }

    override var isAsynchronous: Bool { true }

    override func start() {
        if isCancelled {
            finish()
            return
        }
        isExecuting = true
        main()
    }

    override func main() {
        // Subclasses override and must call finish() when done
        finish()
    }

    func finish() {
        if isExecuting { isExecuting = false }
        if !isFinished { isFinished = true }
    }
}


