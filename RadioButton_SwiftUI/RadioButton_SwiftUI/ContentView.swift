//
//  ContentView.swift
//  RadioButton_SwiftUI
//
//  Created by www.JaneshSwift.com on 05/09/22.
//


import SwiftUI

struct ContentView: View {
    
    @State var objectsArray = ["India", "USA", "China","Brazil"]
    @State var selectedRadioButton = "India"
    
    var body: some View {
        VStack {
            Text("Select Country")
                .font(Font.largeTitle)
                .foregroundColor(.red)
            RadioButtons(items: objectsArray,
                         callbackForSelection:  { selectedVal in
                print("Selected Value  -- : \(selectedVal)")
                selectedRadioButton = selectedVal
            },selectedId: selectedRadioButton)
            Text("Selected --:  \(selectedRadioButton)")
            Spacer()
        }
    }
}

struct RadioButtons: View {
    
    let items : [String]
    let callbackForSelection: (String) -> ()
    @State var selectedId: String = ""
    
    var body: some View {
        List {
            ForEach(0..<items.count, id: \.self) { index in
                RadioButtonView(self.items[index],
                                callback: self.radioGroupCallback,
                                selectedID: self.selectedId)
            }

        }.listStyle(PlainListStyle())
        
    }
    
    func radioGroupCallback(id: String) {
        selectedId = id
        callbackForSelection(id)
    }
}

struct RadioButtonView: View {
    
    let currentRadioValue: String
    let callbackForSelection: (String)->()
    let prevselectedValue : String
    
    init(
        _ id: String,
        callback: @escaping (String)->(),
        selectedID: String
    ) {
        self.currentRadioValue = id
        self.prevselectedValue = selectedID
        self.callbackForSelection = callback
    }
    
    var body: some View {
        Button(action:{
            self.callbackForSelection(self.currentRadioValue)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.prevselectedValue == self.currentRadioValue ? "largecircle.fill.circle" : "circle")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                Text(currentRadioValue)
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
