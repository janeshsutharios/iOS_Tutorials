//
//  GridLayout.swift
//  SwiftUI_LayoutBuilding
//
//  Created by JaneshSwift.com on 29/08/22.
//

import SwiftUI

struct CustomGridLayout: View {
    let itemsRangeForGrid = 1...4
    let gridRows = [
        GridItem(spacing:5),
        GridItem(spacing: 5),
    ]
    
    let gridItemWidth = (UIScreen.main.bounds.width-30)/2
    
    var body: some View {
        ScrollView(.horizontal) {
            
            LazyHGrid(rows: gridRows, alignment: .center,spacing: 5) {
                
                ForEach(itemsRangeForGrid, id: \.self) { item in
                    
                    ZStack {
                        VStack(alignment: .center, spacing: 5) {
                            Image(systemName: "tshirt")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 75, alignment: .center)
                                .foregroundColor(.pink)
                            
                                Text("Men Tshirts")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(.system(size: 20))
                                Text("Grab Now")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.green)
                                    .font(.system(size: 10))
                            
                        }.frame(width: gridItemWidth, height:145, alignment: .center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                }
            }
            .frame(height: 300)
        }
        .padding([.leading, .trailing],10)
    }
}

struct GridLayout_Previews: PreviewProvider {
    static var previews: some View {
        CustomGridLayout()
    }
}
