//
//  main.swift
//  iOS-Tutorial
//
//  Created by Janesh Suthar-M2 on 09/07/25.
//

import Foundation
import Combine


let publisher = Just("Hello, Combine!")
// Publisher: Emits values over time. Here Just is publisher
// Subscriber: Listens to a publisher. Here sink is Subscriber.
let cancellable3 = publisher
    .sink { value in
        print("Simple format of Subscriber, recieved value is: ", value)
    }
let cancellable2 = publisher.sink { value in
    print("Is finished ?", value)
} receiveValue: { value in
    print("Recieved value from publisher", value)
}

let publisher1 = PassthroughSubject<String, Never>()//PassthroughSubject<Output, Failure> Hence here we set error type to never
let publisher2 = PassthroughSubject<Int, Never>()

let cancellable = publisher1
    .combineLatest(publisher2)
    .map { (city, temperature) in
        "City: \(city), Temp: \(temperature)"
    }
    .sink { print($0) }

publisher1.send("New York")        // Nothing emitted yet (publisher2 hasn't sent)
publisher2.send(30)                // Emits: ("New York", 30)
// cancellable.cancel()// <<-- If you want to stop execution..
publisher1.send("San Francisco")   // Emits: ("San Francisco", 30)
publisher2.send(22)                // Emits: ("San Francisco", 22)

enum ThemeMode: String {
    case light, dark
}

let currentTheme: CurrentValueSubject<ThemeMode, Never> = .init(.light)
print("---------------------------------------------------------")

let passthrough = PassthroughSubject<String, Never>()
let currentValue = CurrentValueSubject<String, Never>("Initial")
var c1 = Set<AnyCancellable>()
var c2 = Set<AnyCancellable>()

passthrough.send("A") // No subscribers: value lost
currentValue.send("B") // Subscribers will get B

passthrough
    .sink { print("Passthrough got: \($0)") }
    .store(in: &c1)

currentValue
    .sink { print("CurrentValue got: \($0)") }
    .store(in: &c2)

passthrough.send("C") // Will print now
currentValue.send("D") // Will print
/*

| Topic                 | `PassthroughSubject`             | `CurrentValueSubject`                  |
| --------------------- | -------------------------------- | -------------------------------------- |
| Memory of past value? | ❌ No                             | ✅ Yes                                  |
| Emits immediately?    | ❌ No (only when `.send` happens) | ✅ Yes (sends current + new)            |
| Ideal for             | Events, triggers, notifications  | State management, selected item, cache |
| Access current value? | ❌ No                             | ✅ `.value`                             |
 */
                            
print("---------------------------------------------------------")

//✅ 1. combineLatest – Combine 2 Publishers’ Latest Values
//🧪 Real Use Case: Login form (email + password)

let email = PassthroughSubject<String, Never>()
let password = PassthroughSubject<String, Never>()
var loginCancellable = Set<AnyCancellable>()
email
    .combineLatest(password)
    .sink { latestEmail, latestPassword in
        print("🟢 Email: \(latestEmail), Password: \(latestPassword)")
    }
    .store(in: &loginCancellable)

email.send("user@example.com") // ⚠️ No output yet (password missing)
password.send("1234")          // ✅ Now emits
email.send("admin@example.com") // ✅ Emits with latest password

print("---------------------------------------------------------")

//✅ 2. zip – Pairs emissions 1-to-1
//🧪 Real Use Case: Quiz game where question and answer must align
let questions = PassthroughSubject<String, Never>()
let answers = PassthroughSubject<String, Never>()
var qnaCancellable = Set<AnyCancellable>()

questions
    .zip(answers)
    .sink { question, answer in
        print("❓ \(question) → ✅ \(answer)")
    }
    .store(in: &qnaCancellable)

questions.send("Capital of France?")
answers.send("Paris")           // ✅ Emits pair

questions.send("Capital of Italy?")
answers.send("Rome")            // ✅ Emits pair

// 🧠 Output only happens when both have a new unpaired value
print("---------------------------------------------------------")


//✅ 3. merge – Emits from whichever publisher fires
//🧪 Real Use Case: Merge 2 event streams (user taps or system notifications)

let taps = PassthroughSubject<String, Never>()
let notifications = PassthroughSubject<String, Never>()
var notificationCancellable = Set<AnyCancellable>()

taps
    .merge(with: notifications)
    .sink { event in
        print("📣 Event: \(event)")
    }
    .store(in: &notificationCancellable)

taps.send("User tapped login")
notifications.send("Token expired")
taps.send("User tapped logout")
// 🧠 Emits values immediately as any publisher fires
print("---------------------------------------------------------")

func fetchGreeting() async -> String {
    return "Hello, Combine + Concurrency!"
}

Task {
    let greeting = await fetchGreeting()
    print(greeting)

    do {
        let user = try await fetchUser()
        print("User name: \(user.name)")
    } catch {
        print("❌ Failed: \(error)")
    }
}
struct User: Decodable {
    let id: Int
    let name: String
}

func fetchUser() async throws -> User {
    let url = URL(string: "https://jsonplaceholder.typicode.com/users/1")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}


await asyncExample()

//var c11 = Set<AnyCancellable>()
//loadName()
//    .sink(receiveCompletion: { print($0) },
//          receiveValue: { name in print("Name is \(name)") })
//    .store(in: &c11)
//
//func loadName() -> Future<String, Error> {
//    return Future { promise in
//        // Simulate delay
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            let success = Bool.random()
//            if success {
//                promise(.success("Alice"))
//            } else {
//                promise(.failure(NSError(domain: "fail", code: 1)))
//            }
//        }
//    }
//}
/**
 In a multithreaded program, shared mutable state can lead to data races.
 Swift `actor`s solve this by **serializing access** to their internal state — ensuring that only one task at a time can access or mutate it.

 ### Actor Features

 | Feature                  | Description                                                                 |
 |--------------------------|-----------------------------------------------------------------------------|
 | Reference Type           | ✅ Yes                                                                       |
 | Thread-Safe by Default   | ✅ Yes – internal state is isolated and synchronized automatically           |
 | Mutable State Isolation  | ✅ Yes – protects mutable properties from concurrent access                  |
 | External Access          | ✅ Requires `await` for methods/properties that can suspend (`async`) calls |

 Use `actor`s when you need to protect shared, mutable state in concurrent Swift code.
 */


actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func get() -> Int {
        return value
    }
    
    // Sometimes you want an actor method that doesn’t need to access isolated state. Use nonisolated:
    // No await needed to call it.
    
    nonisolated func logInfo(_ message: String) {
        print("Info: \(message)")
        
    }
}

func counterExample() {
    let counter = Counter()
    Task {
        await counter.increment()
        print("Counter Value:", await counter.get()) // Prints 1
    }
    counter.logInfo("This is nonisolated")// No await needed to call it.
}
counterExample()
/******************************/

// Example of sendable
struct UserSettings {
    var theme: String = "Light"
}

func useInDetachedTask(settings: UserSettings) {
    Task.detached {
        print("Theme: \(settings.theme)")
    }
}
// Note # actors & struct are already sendable by default. but classes are not Why? Because class instances can be shared mutable state, which isn't safe across threads.
// Task.detached creates a new, independent concurrent task that runs outside the current actor context.


// To silance warning use  @unchecked Sendable {Only do this if you are 100% sure: All properties are immutable OR You've synchronized access (e.g., with actors or locks)
final class CarSettings: @unchecked Sendable {
    let temprature: Int
    init(temprature: Int) {
        self.temprature = temprature
    }
}

func useSafely(settings: CarSettings) {
    Task.detached {
        print("temprature: \(settings.temprature)")
    }
}

// Making class as sendable
final class MyLogger: Sendable {
    let message: String

    init(message: String) {
        self.message = message
    }
}

func detachTaskExample(logger: MyLogger) {
    Task.detached {
        print("message: \(logger.message)")
    }
}

func exampleOfClassWithSendableProperties() {
    let logger = MyLogger(message: "Hello World! from class Sendable detched task")
    detachTaskExample(logger: logger)
}
exampleOfClassWithSendableProperties()
// Use @concurrent to run on background thread. example fetchImage and decode image. for display Image use @mainactor
// preconcurrency to silence the warning
// MARK: - actor example
//Isolation: Actors run in their own independent domain. Access to their properties is serialized, which means only one task can interact with an actor's state at one time.
// Define an actor
actor BankAccount {
    var balance: Double = 0.0

    func deposit(amount: Double) {
        balance += amount
    }

    func withdraw(amount: Double) {
        balance -= amount
    }
    
    func getBalance() -> Double {
        return balance
    }
}

// Using the actor
func performTransactions() async {
    let account = BankAccount()
    await account.deposit(amount: 100.0) // Asynchronous call
    await account.withdraw(amount: 10) // Asynchronous call
    let currentBalance = await account.getBalance() // Asynchronous call
    print("Current balance: \(currentBalance)")
}
await performTransactions()
printIsEmptyOrWhitespace()
try! await testFailingPublisher()
