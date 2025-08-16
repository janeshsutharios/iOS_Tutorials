//
//  ResilientTask.swift
//  JWTClient-iOS
//
//  Created by Janesh Suthar on 16/08/25.
//


/// Represents a unit of async work with an identifier.
struct ResilientTask<ID: Hashable, Output> {
    let id: ID
    let action: () async throws -> Output
}

/// Runs tasks concurrently, collects results & failures.
/// Optionally retries failed tasks with a new context (e.g. new token).
struct ResilientTaskGroup<ID: Hashable, Output> {
    
    /// Run all tasks, retry failed ones once if a retry closure is provided.
    static func run(
        tasks: [ResilientTask<ID, Output>],
        retryOnFailure: (([ResilientTask<ID, Output>]) async -> [ResilientTask<ID, Output>])? = nil
    ) async -> (
        successes: [ID: Output],
        failures: [ID: Error]
    ) {
        // First attempt
        let (successes, failures) = await execute(tasks)
        
        guard !failures.isEmpty, let retry = retryOnFailure else {
            return (successes, failures)
        }
        
        // Retry only failed tasks
        let retryTasks = await retry(
            failures.map { failed in
                tasks.first { $0.id == failed.key }!
            }
        )
        
        let (retrySuccesses, retryFailures) = await execute(retryTasks)
        
        // Merge results
        return (
            successes.merging(retrySuccesses, uniquingKeysWith: { $1 }),
            retryFailures
        )
    }
    
    /// Executes tasks concurrently, collecting successes & failures
    private static func execute(
        _ tasks: [ResilientTask<ID, Output>]
    ) async -> (
        successes: [ID: Output],
        failures: [ID: Error]
    ) {
        var successes: [ID: Output] = [:]
        var failures: [ID: Error] = [:]
        
        await withTaskGroup(of: (ID, Result<Output, Error>).self) { group in
            for task in tasks {
                group.addTask {
                    do {
                        return (task.id, .success(try await task.action()))
                    } catch {
                        return (task.id, .failure(error))
                    }
                }
            }
            
            for await (id, result) in group {
                switch result {
                case .success(let output):
                    successes[id] = output
                case .failure(let error):
                    failures[id] = error
                }
            }
        }
        return (successes, failures)
    }
}
