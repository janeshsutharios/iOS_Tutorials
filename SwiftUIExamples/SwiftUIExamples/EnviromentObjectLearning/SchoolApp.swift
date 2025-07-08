//
//  SchoolApp.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 08/07/25.
//

import SwiftUI

struct SchoolName: EnvironmentKey {
    static let defaultValue = "Xavier"
}

extension EnvironmentValues {
    var schoolName: String {
        get { self[SchoolName.self] }
        set { self[SchoolName.self] = newValue }
    }
}

class StudentModel: ObservableObject {
    @Published var studentName: String = ""
}

struct StudentView: View {
    
    @EnvironmentObject var studentModel: StudentModel
    @State var studentNameEntered: String = ""
    @Environment(\.openURL) var openURL

    var body: some View {
        TextField("Enter Student Name", text: $studentNameEntered)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(Color.red.opacity(0.2))
            .padding()
        Button {
            studentModel.studentName = studentNameEntered
        } label: {
            Text("Submit")
                .foregroundStyle(.white)
                .font(.title2)
                .frame(width: 100, height: 60)
                .background(Color.green)
                .padding()
        }
        HStack {
            Text("Student Name is: ")
            Text(studentModel.studentName)
        }
        Button {
            openURL.callAsFunction(URL(string: "https://www.google.com")!)
        } label: {
            Text("Visit School Website")
        }

    }
}

struct SchoolApp: View {
    
    @Environment(\.schoolName) var schoolName: String
    @StateObject var studentModel: StudentModel = StudentModel()
    
    var body: some View {
        VStack {
            Text("Welcome to, \(schoolName)!" )
            
            StudentView()
        }
        .environmentObject(studentModel)// For first time we have to inject environmentObject
    }
}

#Preview {
    SchoolApp()
        .environment(\.schoolName, "St. Paul School")
}
