import Foundation

/// Standard error response from API
public struct ErrorResponse: Codable, Error, LocalizedError, Sendable {
    public let error: String
    public let statusCode: Int?
    
    public init(error: String, statusCode: Int? = nil) {
        self.error = error
        self.statusCode = statusCode
    }
    
    enum CodingKeys: String, CodingKey {
        case error
        case statusCode
    }
    
    public var errorDescription: String? {
        error
    }
}
