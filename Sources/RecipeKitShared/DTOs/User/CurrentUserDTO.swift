import Foundation

/// Public user information returned by GET /api/auth/me
public struct CurrentUserDTO: Codable, Sendable {
    public let id: UUID
    public let email: String
    public let name: String
    public let picture: String?
    
    public init(id: UUID, email: String, name: String, picture: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.picture = picture
    }
    
    /// Convert to full User model (with timestamps)
    public func toUser(googleId: String = "", createdAt: Date = Date(), updatedAt: Date = Date()) -> User {
        User(
            id: id,
            googleId: googleId,
            email: email,
            name: name,
            picture: picture,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
