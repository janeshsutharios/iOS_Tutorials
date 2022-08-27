//
//  SideBarMenu.swift
//  SideBar_SwiftUI
//
//  Created by JaneshSwift.com on 27/08/22.
//

import SwiftUI
// HamburgerView
struct SideBarView:View {
    
    @EnvironmentObject var viewModel:ViewModel
    
    var body: some View {
        
        ZStack {
            if self.viewModel.isMenuVisible {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                VStack(alignment: .leading) {
                    Image(systemName: "brain.head.profile")
                        .resizable()
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 1))
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    Text("SwiftUI Menu")
                        .font(.largeTitle)
                    Text("You Did It")
                        .font(.caption)
                    Divider()
                    
                    ScrollView {
                        ForEach((1...40), id: \.self) {
                            Text("Side Menu Index---> \($0)")
                        }
                    }
                    Divider()
                    Text("bottom")
                    
                }
                .padding([.bottom, .top],50)
                .padding(.leading, 20)
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(5)
                .padding(.trailing,50)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)
                    )
                ).zIndex(1)  // to force keep at top where removed!!
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: self.viewModel.isMenuVisible)  // << here !!
    }
}
