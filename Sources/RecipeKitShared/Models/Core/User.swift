import Foundation

/// Represents a user in the system
public struct User: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let googleId: String
    public let email: String
    public let name: String
    public let picture: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        googleId: String,
        email: String,
        name: String,
        picture: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.googleId = googleId
        self.email = email
        self.name = name
        self.picture = picture
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /// User's initials for display (e.g., "JD" for John Doe)
    public var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1).uppercased()
            let last = components[1].prefix(1).uppercased()
            return "\(first)\(last)"
        }
        return String(name.prefix(2).uppercased())
    }
    
    /// User's display name
    public var displayName: String {
        name
    }
}

// MARK: - Codable Conformance
extension User {
    enum CodingKeys: String, CodingKey {
        case id
        case googleId = "googleId"
        case email
        case name
        case picture
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

// MARK: - Sample Data for SwiftUI Previews
#if DEBUG
extension User {
    public static let sample = User(
        id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440000")!,
        googleId: "123456789",
        email: "john.doe@example.com",
        name: "John Doe",
        picture: "https://example.com/avatar.jpg",
        createdAt: Date(),
        updatedAt: Date()
    )
}
#endif
