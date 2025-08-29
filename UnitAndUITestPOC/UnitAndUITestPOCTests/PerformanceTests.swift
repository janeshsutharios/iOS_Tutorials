//
//  PerformanceTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class PerformanceTests: XCTestCase {
    
    // MARK: - Model Performance Tests
    
    func testFoodItemFormattedPricePerformance() {
        let foodItem = FoodItem(
            id: 1,
            name: "Performance Test Pizza",
            description: "Delicious performance test pizza",
            price: 12.99,
            imageUrl: "https://example.com/pizza.jpg",
            category: "Performance"
        )
        
        measure {
            for _ in 0..<10000 {
                let _ = foodItem.formattedPrice
            }
        }
    }
    
    func testLoginRequestCodingPerformance() throws {
        let loginRequest = LoginRequest(username: "performanceuser", password: "performancepass")
        
        measure {
            for _ in 0..<1000 {
                let encoder = JSONEncoder()
                let _ = try? encoder.encode(loginRequest)
            }
        }
    }
    
    func testLoginResponseDecodingPerformance() throws {
        let jsonString = """
        {
            "accessToken": "performance-test-token",
            "refreshToken": "performance-refresh-token"
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for _ in 0..<1000 {
                let decoder = JSONDecoder()
                let _ = try? decoder.decode(LoginResponse.self, from: data)
            }
        }
    }
    
    func testFoodItemsResponseDecodingPerformance() throws {
        let jsonString = """
        {
            "foodItems": [
                {
                    "id": 1,
                    "name": "Performance Pizza",
                    "description": "Delicious performance pizza",
                    "price": 12.99,
                    "imageUrl": "https://example.com/pizza.jpg",
                    "category": "Performance"
                },
                {
                    "id": 2,
                    "name": "Performance Burger",
                    "description": "Delicious performance burger",
                    "price": 8.99,
                    "imageUrl": "https://example.com/burger.jpg",
                    "category": "Performance"
                }
            ]
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        measure {
            for _ in 0..<1000 {
                let decoder = JSONDecoder()
                let _ = try? decoder.decode(FoodItemsResponse.self, from: data)
            }
        }
    }
    
    // MARK: - ViewModel Performance Tests
    
    func testLoginViewModelStateChangesPerformance() async {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        measure {
            for i in 0..<1000 {
                viewModel.authState = .loading
                viewModel.authState = .authenticated
                viewModel.authState = .error("Performance test error \(i)")
                viewModel.authState = .idle
            }
        }
    }
    
    func testFoodViewModelStateChangesPerformance() async {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        let foodItems = [
            FoodItem(id: 1, name: "Performance Pizza", description: "Delicious performance pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Performance"),
            FoodItem(id: 2, name: "Performance Burger", description: "Delicious performance burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "Performance")
        ]
        
        measure {
            for _ in 0..<1000 {
                viewModel.foodState = .loading
                viewModel.foodState = .loaded(foodItems)
                viewModel.foodState = .error("Performance test error")
                viewModel.foodState = .idle
            }
        }
    }
    
    func testLoginViewModelComputedPropertiesPerformance() async {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        measure {
            for _ in 0..<10000 {
                let _ = viewModel.isLoading
                let _ = viewModel.errorMessage
            }
        }
    }

    func testFoodViewModelComputedPropertiesPerformance() async {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        let foodItems = [
            FoodItem(id: 1, name: "Performance Pizza", description: "Delicious performance pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Performance"),
            FoodItem(id: 2, name: "Performance Burger", description: "Delicious performance burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "Performance")
        ]
        
        viewModel.foodState = .loaded(foodItems)
        
        measure {
            for _ in 0..<10000 {
                let _ = viewModel.isLoading
                let _ = viewModel.foodItems
                let _ = viewModel.errorMessage
            }
        }
    }
    
    // MARK: - Service Performance Tests
    
    func testAuthServiceLoginPerformance() async {
        let expectedResponse = LoginResponse(accessToken: "performance-token", refreshToken: "performance-refresh")
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockResponse(expectedResponse)
        
        let authService = AuthService(networkService: mockNetworkService)
        
        measure {
            Task {
                for _ in 0..<100 {
                    let _ = try? await authService.login(username: "performanceuser", password: "performancepass")
                }
            }
        }
    }
    
    func testFoodServiceFetchFoodItemsPerformance() async {
        let expectedFoodItems = [
            FoodItem(id: 1, name: "Performance Pizza", description: "Delicious performance pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Performance"),
            FoodItem(id: 2, name: "Performance Burger", description: "Delicious performance burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "Performance")
        ]
        
        let mockResponse = FoodItemsResponse(foodItems: expectedFoodItems)
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockResponse(mockResponse)

        let foodService = FoodService(networkService: mockNetworkService)
        
        measure {
            Task {
                for _ in 0..<100 {
                    let _ = try? await foodService.fetchFoodItems(token: "performance-token")
                }
            }
        }
    }
    
    // MARK: - Network Performance Tests
    
    func testAPIEndpointURLGenerationPerformance() {
        let loginRequest = LoginRequest(username: "performanceuser", password: "performancepass")
        
        measure {
            for _ in 0..<10000 {
                let endpoint = APIEndpoint.login(loginRequest)
                let _ = endpoint.url
            }
        }
    }
    
    func testAPIEndpointBodyGenerationPerformance() {
        let loginRequest = LoginRequest(username: "performanceuser", password: "performancepass")
        
        measure {
            for _ in 0..<1000 {
                let endpoint = APIEndpoint.login(loginRequest)
                let _ = endpoint.body
            }
        }
    }
    
    // MARK: - Large Data Performance Tests
    
    func testLargeFoodItemsResponseDecodingPerformance() async throws {
        // Create a large JSON response with many food items
        var foodItems: [[String: Any]] = []
        for i in 1...1000 {
            foodItems.append([
                "id": i,
                "name": "Performance Food \(i)",
                "description": "Delicious performance food \(i)",
                "price": Double(i) * 0.99,
                "imageUrl": "https://example.com/food\(i).jpg",
                "category": "Performance"
            ])
        }
        
        let jsonObject = ["foodItems": foodItems]
        let data = try JSONSerialization.data(withJSONObject: jsonObject)
        
        measure {
            for _ in 0..<10 {
                let decoder = JSONDecoder()
                let _ = try? decoder.decode(FoodItemsResponse.self, from: data)
            }
        }
    }
    
    func testLargeFoodItemsViewModelPerformance() async {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        // Create a large array of food items
        var foodItems: [FoodItem] = []
        for i in 1...1000 {
            foodItems.append(FoodItem(
                id: i,
                name: "Performance Food \(i)",
                description: "Delicious performance food \(i)",
                price: Double(i) * 0.99,
                imageUrl: "https://example.com/food\(i).jpg",
                category: "Performance"
            ))
        }
        
        viewModel.foodState = .loaded(foodItems)
        
        measure {
            for _ in 0..<100 {
                let _ = viewModel.foodItems.count
                let _ = viewModel.foodItems.first?.name
                let _ = viewModel.foodItems.last?.name
            }
        }
    }
}
