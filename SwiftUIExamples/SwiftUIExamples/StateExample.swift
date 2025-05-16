//
//  ContentView.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 12/05/25.
//

import SwiftUI

struct TextFieldExample: View {
    @State private var name = ""

    var body: some View {
        VStack {
            TextField("Enter name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Text("Hello, \(name)")
        }
    }
}

struct ContentView: View {
    
    var body: some View {
        TextFieldExample()
    }
}

#Preview {
    ContentView()
}
