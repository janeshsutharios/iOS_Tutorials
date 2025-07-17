//
//  CombineExamples.swift
//  SwiftUI-CommandLineTool
//
//  Created by JANESH SUTHAR on 15/07/25.
//

import Foundation
import Combine

func asyncExample() async {
    do {
        let data = try await fetchData()
        print("Received data:", data)
    } catch {
        print("Failed with error:", error)
    }
}

func fetchData() async throws -> String {
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
    return "User data"
}

