//
//  SwiftUIExamplesApp.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 12/05/25.
//

import SwiftUI

@main
struct SwiftUIExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
    }
}

struct DashboardView: View {
    private var examples: [ExampleItem] = [
        ExampleItem(title: "State example", destination: AnyView(TwoWayBindingParentView())),
        ExampleItem(title: "Two way binding", destination: AnyView(TextFieldExample())),
        ExampleItem(title: "Login View", destination: AnyView(LoginView())),
        ExampleItem(title: "Search View", destination: AnyView(SearchView())),
        ExampleItem(title: "School App", destination:
                        AnyView(
                            SchoolApp()
                                .environment(\.schoolName, "St. Paul")
                        )
                   ),
        ExampleItem(title: "Learn flapMap & switch Latest |", destination: AnyView(GitHubSearchView())),
        ExampleItem(title: "Learn flapMap & switch Latest || ", destination: AnyView(GitHubSearchView2())),
        ExampleItem(title: "RetryCatchExample ", destination: AnyView(RetryCatchExample())),
        ExampleItem(title: "ButtonThrottle ", destination: AnyView(ButtonThrottle())),
        ExampleItem(title: "Handle events ", destination: AnyView(GitHubSearchView3())),
        ExampleItem(title: "Aync Await with Static Data protocols", destination: AnyView(UserListView())),
        ExampleItem(title: "Aync Await with  API and protocols tests", destination: AnyView(RepoListView(username: "janeshsutharios"))),
        ExampleItem(title: "Dependency-Injection ", destination: AnyView(ProjectsListView())),
        ExampleItem(title: "MemoryLeakExamples ", destination: AnyView(MemoryLeakExamples())),
        ExampleItem(title: "Actors example ", destination: AnyView(FoodListView())),

    ]
    var body: some View {
        NavigationView {
            List(examples) { item in
                NavigationLink(destination: item.destination) {
                    Text(item.title)
                        .font(.headline)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("🚀 SwiftUI Learning")
        }
    }
}

struct ExampleItem: Identifiable {
    let id = UUID()
    let title: String
    let destination: AnyView
}
