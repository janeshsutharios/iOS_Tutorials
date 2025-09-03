struct FoodItem: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let category: String
}
