//
//  ContentView.swift
//  SideBar_SwiftUI
//
//  Created by JaneshSwift.com on 26/08/22.
//

import SwiftUI

// Dashboard view with Hamburger Menu
struct DashBoardView: View {
    // 1: View Model For managing sideBar flag
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        
        ZStack {
            NavigationView {
                VStack(alignment:.leading) {
                    List {
                        ForEach((1...130), id: \.self) {
                            Text("Index---> \($0)")
                        }
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                // Setup Hamburger Icon On NaviationBar
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.viewModel.isMenuVisible.toggle()
                        }, label: {
                            HStack {
                                Image(systemName: "sidebar.leading")
                                Text("Home").font(.headline)
                            }
                        })
                        .foregroundColor(.blue) // You can apply colors and other modifiers too
                    }
                }
            }
            
            SideBarView()
                .ignoresSafeArea()
            // .background(Color.clear.edgesIgnoringSafeArea(Edge.Set.all))
            
        }.environmentObject(self.viewModel)
            .gesture(customDrag)
    }
    
    // Adding Drag Gesture - Swipe from Left with edge of $0.location.x < 200
    var customDrag: some Gesture {
        
        return DragGesture(minimumDistance: 5)
            .onEnded {
                if ($0.location.x - $0.startLocation.x) > 0 {// To enable Left to Right Swipe
                    //print("rRight Swipe--->", $0.translation.width, self.viewModel.isLeftMenuVisible)
                    if $0.location.x < 200 && !self.viewModel.isMenuVisible {
                        //print("dsdsd",$0.translation.width, $0.location, UIScreen.main.bounds.width)
                        withAnimation {
                            self.viewModel.isMenuVisible.toggle()
                        }
                    }
                } else {
                    //print("Left Swipe ---")
                    if $0.translation.width < -100 && self.viewModel.isMenuVisible {
                        withAnimation {
                            self.viewModel.isMenuVisible.toggle()
                        }
                    }
                }
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashBoardView()
    }
}
