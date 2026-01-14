import Foundation

/// Success response for operations that don't return data
public struct SuccessResponse: Codable, Sendable {
    public let success: Bool
    
    public init(success: Bool = true) {
        self.success = success
    }
}
