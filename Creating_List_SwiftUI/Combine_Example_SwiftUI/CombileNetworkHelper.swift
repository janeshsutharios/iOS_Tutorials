//
//  CombileNetworkHelper.swift

// For Tutorial visit www.JaneshSwift.com
// https://janeshswift.com/ios/swiftui/how-to-use-datataskpublisher-combine-framework/

import Foundation
import Combine

// MARK: Model for JSON Data -- For Converting Network Data object into swift readable data object
struct GithubEntity: Codable {
    var id: Int?
    var nodeID, name, fullName: String?
}

// MARK: Custom Error enum
enum WebServiceError: Error, LocalizedError {
    case unknown, customError(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "---Unknown error----"
        case .customError(let reason):
            return reason
        }
    }
}

struct CombileNetworkHelper {
    
    static func fetchFromWebService() -> AnyPublisher<[GithubEntity], WebServiceError> {
        // 1: GET Service URL
        let url = URL(string: "https://api.github.com/users/janeshsutharios/repos")!
        
        let urlRequest = URLRequest(url: url)
        
        // 2: Added Publisher
        var dataPublisher: AnyPublisher<[GithubEntity], WebServiceError>
        
        // 3: DataTaskPublisher to fetch stream values
        dataPublisher = URLSession.DataTaskPublisher(request: urlRequest, session: .shared)
        
        // 4: tryMap for Creating a closuer to map elements with Publisher
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw WebServiceError.unknown
                }
                return data
            }
        // 5: Convert Response to Codable mode
            .decode(type: [GithubEntity].self, decoder: JSONDecoder())
        // 6: After Recieve data jump to Main Thread so it will be thread safe for UI Activities
            .receive(on: RunLoop.main)
        // 7: mapError is used to map error of custom type with closure
            .mapError { error in
                if let error = error as? WebServiceError {
                    return error
                } else {
                    return WebServiceError.customError(reason: error.localizedDescription)
                }
            }
        // 8:eraseToAnyPublisher is used to expose an instance of AnyPublisher to the downstream subscriber, rather than this publisher’s actual type
            .eraseToAnyPublisher()
        return dataPublisher
    }
}
