//
//  NetworkHelper.swift
//  InfiniteListSwiftUI
//
//  Created by Janesh on 17/08/21.


import SwiftUI

struct ContentView: View {
    
    @State private var isLoading: Bool = false
    
    @State private var page: Int = 0
    
    @State private var items:[Item] = []
    private let offset: Int = 10
    
    var body: some View {
        NavigationView {
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.name!)
                        .font(.headline)
                    Text(item.fullName!)
                    //                        .frame(height:300)
                    //let _ = print("Last Item------>", items.isLastItem(item, itemCount: items.count))
                    if isLoading && items.isLastItem(item) {
                        // print("Loading ....")
                        Divider()
                        Spinner(style: .medium)
                            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                    }
                }.onAppear {
                    listItemAppears(item)
                }
            }.onAppear(perform: loadData)
        }
//        .navigationTitle("List of items")
//        .toolbar {
//            ToolbarItem {
//                Text("Page index: \(page)")
//            }
//        }
    }
    
    
    func loadData() {
        var urlString = "https://api.github.com/search/repositories?q=swift&sort=stars&per_page=20&page=\(page)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        print("Making request for page--->", page)
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            // step 4
            isLoading = false
            print("Data for URL-> ", urlString)
            print("data found-->", data)
           // print("Response found-->", response)
            print("Error found-->", error)

            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(GitResponseEntity.self, from: data)
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.items += decodedResponse.items ?? []
                        //  print("result--->", items)
                    }
                } catch {
                    print("error", error)
                }
            } else {
                print("erroroo")
            }
            
        }.resume()
    }
}

private extension ContentView {
    func listItemAppears<Item: Identifiable>(_ item: Item) {
        if items.isLastItem(item) {
            isLoading = true
            // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            page += 1
            loadData()
            //}
        } else {
        }
    }
}
