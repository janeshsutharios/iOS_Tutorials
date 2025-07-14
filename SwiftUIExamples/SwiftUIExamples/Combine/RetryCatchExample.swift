//
//  RetryCatch.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 14/07/25.
//

import SwiftUI
import Combine

struct RetryCatchExample: View {
    
    @State var apiResponse: String = ""
    @State private var cancellable: AnyCancellable?

    var body: some View {
        Text("API Response--> " + apiResponse)
            .onAppear {
                 fetchMessage()
            }
            .onDisappear {
                // Important - Cancel service on view disappears.
                cancellable?.cancel()
            }

    }
    
    func fetchMessage() {
        let shouldFail = Bool.random()
        let url = shouldFail
            ? URL(string: "https://invalid.url")!
            : URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MyResponse.self, decoder: JSONDecoder())
            .retry(2)
            .catch { _ in
                Just(MyResponse.placeholder())
            }
            .receive(on: DispatchQueue.main)
            .sink { response in
                self.apiResponse = response.title
            }
        
    }

}

struct MyResponse: Decodable {
    let title: String

    static func placeholder() -> MyResponse {
        return MyResponse(title: "⚠️ Failed. Showing fallback message.")
    }
}


#Preview {
    RetryCatchExample()
}
