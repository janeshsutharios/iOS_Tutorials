//
//  ContentView.swift
//  HideTabBarOnPush_SwiftUI
//
//  Created by JaneshSwift.com  on 04/09/22.
//

import SwiftUI

struct TabBarView: View {
    
    @State var tabSelection: Int = 0
    @State var tabArray = ["Profile", "Settings"]
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabSelection){
                ForEach(0 ..< tabArray.count, id: \.self) { indexValue in
                    NavigationLink(destination: DetailView()){
                        VStack{
                            Text("\(tabArray[indexValue]) tab -- Click to jump next view")
                        }
                    }
                    .tabItem {
                        Image(systemName: "\(indexValue).circle.fill")
                        Text(tabArray[indexValue])
                    }
                    .tag(indexValue)
                    
                }
            }
            .navigationBarTitle(tabArray[tabSelection])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
