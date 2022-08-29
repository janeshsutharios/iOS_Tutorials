//
//  ContentView.swift
//  SwiftUI_LayoutBuilding
//
//  Created by Janesh on 28/08/22.
// More Tutorial at www.JaneshSwift.com
// Find This Tutorial at - https://janeshswift.com/ios/swiftui/how-to-create-complex-ui-with-swiftui/

import SwiftUI

struct ContentView: View {
    
    @State var searchBarText:String = ""
    
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                VStack(alignment: .leading) {
                    SearchBarView(currentSearchText: $searchBarText)
                    
                    LazyHStack {
                        PageView()
                    }
                    .padding([.all], 0)
                    .background(Color.blue)
                    .frame(height:175)
                    
                    Text("Top Deals Of The Day 🌟🌟🌟")
                        .multilineTextAlignment(.leading)
                        .padding(.all, 10)
                        .font(.headline)
                    
                    ProductListView()
                    
                    CustomGridLayout()
                    
                    //Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("🛒Ecom Application").font(.headline)
                            Text("Buy products👕").font(.subheadline)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
