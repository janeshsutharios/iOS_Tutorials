import SwiftUI
import Combine
import AppRouter

public struct OrderSummaryView: View {
    @EnvironmentObject var router: AppRouter
    public let orderedItems: [String]
    
    public init(orderedItems: [String]) {
        self.orderedItems = orderedItems
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("📋 Order Summary")
                .font(.largeTitle)
            
            List(orderedItems, id: \.self) { item in
                Text(item)
            }
            
            Text("Total Items: \(orderedItems.count)")
                .font(.headline)
            Button("Go to Home") {
                router.path = []
            }
        }
        .navigationBarBackButtonHidden()
    }
}
