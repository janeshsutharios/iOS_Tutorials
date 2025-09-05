protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: String { get }
}

extension APIEndpoint {
    var baseURL: String { return "https://api.example.com" }
    var method: String { return "GET" } // Default value
    
    func makeRequest() -> URLRequest {
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}

// Concrete implementations
struct UserEndpoint: APIEndpoint {
    var path: String { return "/users" }
}

struct ProductEndpoint: APIEndpoint {
    var path: String { return "/products" }
    var method: String { return "POST" } // Override default
}

// Usage
let userRequest = UserEndpoint().makeRequest() // Gets default method
let productRequest = ProductEndpoint().makeRequest() // Uses custom method
