//
//  ContentView.swift
//  Creating_List_SwiftUI
//
//  Created by Janesh on 24/08/22.
//

// For Tutorial visit www.JaneshSwift.com
// https://janeshswift.com/ios/swiftui/how-to-use-datataskpublisher-combine-framework/
import SwiftUI
import Combine

struct ContentView: View {
    
    @State var apiDataSubscriber: Cancellable? = nil
    
    func hitWebService() {
        apiDataSubscriber = CombileNetworkHelper.fetchFromWebService().sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { response in
            print("\n Response Recieved-->", response)
        })
    }
    
    var body: some View {
        Button(
            action: { hitWebService() },
            label: { Text("Click Me").font(.subheadline) }
        )
    }
}

struct DeviceList: Identifiable {
    let id:Int
    let name: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


