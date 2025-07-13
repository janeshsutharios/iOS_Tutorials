//
//  BindingExample.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 12/05/25.

// These examples show how data can be passed by reference between parent and child views using @Binding
//It creates a reference to a @State or other mutable value, so child views can modify data owned by a parent.
//Used when you want TWO_WAY data flow from parent to child.


import Foundation
import SwiftUI

// MARK: Parent View
struct TwoWayBindingParentView: View {
    @State private var isOn = false

    var body: some View {
        ToggleView(isOn: $isOn)
        Text("Toggle is \(isOn ? "ON" : "OFF")")
    }
}

// MARK: Child View data passing from parent to child
struct ToggleView: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Toggle", isOn: $isOn)
            .padding()
    }
}

#Preview {
    TwoWayBindingParentView()
}
