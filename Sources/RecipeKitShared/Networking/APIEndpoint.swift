import Foundation

/// Represents an API endpoint with path and method
public struct APIEndpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    
    public init(path: String, method: HTTPMethod = .get) {
        self.path = path
        self.method = method
    }
}

// MARK: - Recipe Endpoints
extension APIEndpoint {
    public static let getAllRecipes = APIEndpoint(path: "/api/recipes", method: .get)
    
    public static func getRecipe(id: UUID) -> APIEndpoint {
        APIEndpoint(path: "/api/recipes/\(id.uuidString)", method: .get)
    }
    
    public static let createRecipe = APIEndpoint(path: "/api/recipes", method: .post)
    
    public static func updateRecipe(id: UUID) -> APIEndpoint {
        APIEndpoint(path: "/api/recipes/\(id.uuidString)", method: .put)
    }
    
    public static func deleteRecipe(id: UUID) -> APIEndpoint {
        APIEndpoint(path: "/api/recipes/\(id.uuidString)", method: .delete)
    }
    
    public static func toggleFavorite(id: UUID) -> APIEndpoint {
        APIEndpoint(path: "/api/recipes/\(id.uuidString)/favorite", method: .patch)
    }
}

// MARK: - Auth Endpoints
extension APIEndpoint {
    public static let getCurrentUser = APIEndpoint(path: "/api/auth/me", method: .get)
    public static let logout = APIEndpoint(path: "/api/auth/logout", method: .post)
    public static let googleLogin = APIEndpoint(path: "/api/auth/google", method: .get)
}

// MARK: - Future: Meal Plan Endpoints (placeholders)
extension APIEndpoint {
    // public static let getAllMealPlans = APIEndpoint(path: "/api/meal-plans", method: .get)
    // Add more when implemented
}

// MARK: - Future: Shopping List Endpoints (placeholders)
extension APIEndpoint {
    // public static let getShoppingList = APIEndpoint(path: "/api/shopping-list", method: .get)
    // Add more when implemented
}
