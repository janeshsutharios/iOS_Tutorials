//
//  ProductListView.swift
//  SwiftUI_LayoutBuilding
//
//  Created by JaneshSwift.com on 29/08/22.
//

import SwiftUI

struct DeviceEntity:Identifiable {
    let id = UUID()
    var name: String
}
struct ProductListView: View {
    
    @State var deviceList:[DeviceEntity] = [DeviceEntity(name: "iPhone 15 Exclusive Offer"),
                                            DeviceEntity(name: "iPhone 14 Exclusive Offer")]
    
    
    var body: some View {
        List(deviceList) { currentObject in
            HStack {
                Image(systemName: "iphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50, alignment: .center)
                    .foregroundColor(.pink)
                
                VStack(alignment: .leading, spacing: 0) {
                    // Spacer()
                    Text(currentObject.name)
                        .padding(.leading,10)
                    HStack{
                        Text("$1000")
                            .strikethrough(true, color: .black)
                            .padding(.leading,10).font(.caption)
                        Text ("$700")
                            .font(Font.headline.weight(.semibold))
                        Text ("30% off")
                            .font(Font.body.weight(.light))
                            .foregroundColor(.green)
                        
                    }
                    //Spacer()
                    .frame(height: 50)
                }//.environment(\.defaultMinListRowHeight, 100)
            }
        }
        .listStyle(.plain)
        .frame(height:170)
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
