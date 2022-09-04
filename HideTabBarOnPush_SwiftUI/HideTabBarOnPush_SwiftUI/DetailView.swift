//
//  DetailView.swift
//  HideTabBarOnPush_SwiftUI
//
//  Created by JaneshSwift.com on 04/09/22.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        Text("Detail View")
            .navigationBarTitle("NavigatedView")
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("helllo")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
