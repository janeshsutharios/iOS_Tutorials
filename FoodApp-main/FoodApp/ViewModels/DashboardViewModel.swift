import Foundation

class DashboardViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var selectedCategory = "All"
    
    private let foodService: FoodServiceProtocol
    
    init(foodService: FoodServiceProtocol = FoodService()) {
        self.foodService = foodService
        fetchFoodItems()
    }
    
    func fetchFoodItems() {
        isLoading = true
        foodService.fetchFoodItems { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.foodItems = items
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var categories: [String] {
        var allCategories = ["All"]
        let itemCategories = Set(foodItems.map { $0.category })
        allCategories.append(contentsOf: itemCategories)
        return allCategories
    }
    
    var filteredItems: [FoodItem] {
        if selectedCategory == "All" {
            return foodItems
        }
        return foodItems.filter { $0.category == selectedCategory }
    }
}
