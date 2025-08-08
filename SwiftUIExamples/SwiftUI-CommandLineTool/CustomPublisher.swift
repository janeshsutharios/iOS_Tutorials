//
//  CustomPublisher.swift
//  SwiftUI-CommandLineTool
//
//  Created by Janesh Suthar on 01/08/25.
//

import Foundation
@preconcurrency import Combine

//Build a custom Combine operator
//Let’s build an operator called .isEmptyOrWhitespace() for Publisher<String, Failure>
//It emits:
//true if the string is empty or whitespace
//false otherwise

// 1. Define a custom Publisher wrapper
struct IsEmptyOrWhitespacePublisher<Upstream: Publisher>: Publisher where Upstream.Output == String {
    typealias Output = Bool
    typealias Failure = Upstream.Failure

    let upstream: Upstream

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        upstream
            .map { str in
                str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .receive(subscriber: subscriber)
    }
}
// 2. Add a convenience extension on Publisher
extension Publisher where Output == String {
    func isEmptyOrWhitespace() -> IsEmptyOrWhitespacePublisher<Self> {
        return IsEmptyOrWhitespacePublisher(upstream: self)
    }
}
// 3. Usage
func printIsEmptyOrWhitespace() {
    _ = Just("  ")
        .isEmptyOrWhitespace()
        .sink { isEmpty in
            print("Is empty or whitespace:", isEmpty) // true
        }
}

// MARK: - A custom Combine operator that retries a failing publisher N times, with a delay between attempts. Super useful for: Network requests, Database retries, Resilient logic in unstable environments

extension Publisher {
    func retryWithDelay(retries: Int, delay: TimeInterval, scheduler: DispatchQueue = .main) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            guard retries > 0 else {
                return Fail(error: error).eraseToAnyPublisher()
            }

            return Just(())
                .delay(for: .seconds(delay), scheduler: scheduler)
                .flatMap { _ in
                    self.retryWithDelay(retries: retries - 1, delay: delay, scheduler: scheduler)
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}


func testFailingPublisher() async throws {
    let failingPublisher = Future<Int, Error> { promise in
        print("Attempting request...")
        promise(.failure(NSError(domain: "Network", code: -1)))
    }
    _ = failingPublisher
        .retryWithDelay(retries: 3, delay: 2)
        .sink(receiveCompletion: { completion in
            print("Completion:", completion)
        }, receiveValue: { value in
            print("Got value:", value)
        })
}
