//
//  SearchBarView.swift
//  SwiftUI_LayoutBuilding
//
//  Created by Janesh on 28/08/22.
//

import SwiftUI

struct SearchBarView: View {
    
    @State private var isEditingMode = false
    @Binding var currentSearchText: String
 
    var body: some View {
        HStack {
 
            TextField("Search Products Here ..", text: $currentSearchText)
                .padding(8)
                .padding(.horizontal, 26)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 7)

                        if isEditingMode {
                            Button(action: {
                                self.currentSearchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 7)
                            }
                        }
                    }
                )
                .padding(.horizontal, 9)
                .onTapGesture {
                    self.isEditingMode = true
                }
 
            if isEditingMode {
                Button(action: {
                    self.isEditingMode = false
                    self.currentSearchText = ""
 
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 9)
                .animation(.easeOut)
            }
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(currentSearchText: .constant(""))
        
    }
}
