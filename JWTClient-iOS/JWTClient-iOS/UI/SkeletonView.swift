import SwiftUI

// Custom loader if needs to be add
struct SkeletonView: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.3))
            .mask(
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                               startPoint: .leading, endPoint: .trailing)
                    .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
            .cornerRadius(10)
            .frame(height: 18)
    }
}
