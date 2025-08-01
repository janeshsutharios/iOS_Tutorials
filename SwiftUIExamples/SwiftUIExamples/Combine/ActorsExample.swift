import SwiftUI
import Foundation

// MARK: - Data Models
struct MealCategoryResponse: Decodable {
    let categories: [Food]
}

struct Food: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let thumbnailURL: URL
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case name = "strCategory"
        case thumbnailURL = "strCategoryThumb"
        case description = "strCategoryDescription"
    }
}
// MARK: - Actor

/// Actor that manages fetching and storing food items in a thread-safe way.
actor FoodStore {
    private(set) var foods: [Food] = []
    
    func fetchFoodData() async throws {
        guard let url = URL(string: "https://github.com/janeshsutharios/REST_GET_API/raw/refs/heads/main/food.json") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedFoods = try JSONDecoder().decode(MealCategoryResponse.self, from: data)
        self.foods = decodedFoods.categories
    }
    
    func getFoods() -> [Food] {
        return foods
    }
}

// MARK: - ViewModel
@MainActor
class FoodViewModel: ObservableObject {
    @Published var items: [Food] = []
    @Published var error: String? = nil
    private let store = FoodStore()

    func load() {
        Task {
            let result = await getFoods()
            switch result {
            case .success(let foods):
                await MainActor.run {
                    self.items = foods
                    self.error = nil
                }
            case .failure(let err):
                await MainActor.run {
                    self.error = err.localizedDescription
                }
            }
        }
    }

    nonisolated func getFoods() async -> Result<[Food], Error> {
        do {
            try await store.fetchFoodData()
            let foods = await store.getFoods()
            return .success(foods)
        } catch {
            return .failure(error)
        }
    }

}

// MARK: - View

struct FoodListView: View {
    @StateObject private var viewModel = FoodViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.items) { item in
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: item.thumbnailURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("🍱 Food Menu")
            .onAppear {
                viewModel.load()
            }
            .overlay {
                if let error = viewModel.error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FoodListView()
    }
}
