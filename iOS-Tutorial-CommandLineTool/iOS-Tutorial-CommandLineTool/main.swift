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

// ✅ Keep app alive to see output
RunLoop.main.run()


