import SwiftUI
import Foundation

// MARK: - Thread Inspection Utility
func currentThreadInfo(_ label: String = "") -> String {
    print("-------------------")
    let thread = Thread.current
    return """
    \(label.isEmpty ? "" : "\(label): ")
    Thread: \(thread.description)
    IsMainThread: \(thread.isMainThread)
    QualityOfService: \(thread.qualityOfService.rawValue)
    """
}

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
actor FoodStore {
    private(set) var foods: [Food] = []
    
    func fetchFoodData() async throws {
        print(currentThreadInfo("FoodStore.fetchFoodData start"))
        
        guard let url = URL(string: "https://github.com/janeshsutharios/REST_GET_API/raw/refs/heads/main/food.json") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        print(currentThreadInfo("FoodStore received network response"))
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decodedFoods = try JSONDecoder().decode(MealCategoryResponse.self, from: data)
        self.foods = decodedFoods.categories
        
        print(currentThreadInfo("FoodStore decode completed"))
    }
    
    func getFoods() -> [Food] {
        print(currentThreadInfo("FoodStore.getFoods"))
        return foods
    }
}

// MARK: - ViewModel
@MainActor
final class FoodViewModel: ObservableObject {
    @Published private(set) var items: [Food] = []
    @Published private(set) var error: String? = nil
    @Published private(set) var lastThreadInfo: String = ""
    
    private let store = FoodStore()

    func load() {
        print(currentThreadInfo("FoodViewModel.load start"))
        lastThreadInfo = currentThreadInfo("Load initiated")
        
        Task {
            let result = await getFoods()
            
            switch result {
            case .success(let foods):
                print(currentThreadInfo("FoodViewModel before MainActor assignment"))
                await MainActor.run {
                    self.items = foods
                    self.error = nil
                    self.lastThreadInfo = currentThreadInfo("MainActor update completed")
                    print(self.lastThreadInfo)
                }
            case .failure(let err):
                await MainActor.run {
                    self.error = err.localizedDescription
                    self.lastThreadInfo = currentThreadInfo("Error handling")
                    print(self.lastThreadInfo)
                }
            }
        }
    }

    nonisolated func getFoods() async -> Result<[Food], Error> {
        print(currentThreadInfo("FoodViewModel.getFoods start"))
        
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
        NavigationStack {
            List {
                Section("Thread Info") {
                    Text(viewModel.lastThreadInfo)
                        .font(.caption)
                        .monospaced()
                }
                
                Section("Food Items") {
                    ForEach(viewModel.items) { item in
                        HStack(alignment: .top, spacing: 12) {
                            AsyncImage(url: item.thumbnailURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 90, height: 90)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "photo")
                                        .frame(width: 90, height: 90)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("🍱 Food Menu")
            .refreshable {
                print(currentThreadInfo("Pull-to-refresh start"))
                viewModel.load()
            }
            .task {
                print(currentThreadInfo("Initial load start"))
                viewModel.load()
            }
            .overlay {
                if let error = viewModel.error {
                    VStack {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.load()
                        }
                    }
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
