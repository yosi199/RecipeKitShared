import XCTest
@testable import RecipeKitShared

final class UserTests: XCTestCase {
    
    func testUserCodable() throws {
        let user = User(
            id: UUID(),
            googleId: "123456",
            email: "test@example.com",
            name: "Test User",
            picture: "https://example.com/pic.jpg"
        )
        
        let encoded = try sharedJSONEncoder.encode(user)
        let decoded = try sharedJSONDecoder.decode(User.self, from: encoded)
        
        XCTAssertEqual(user.id, decoded.id)
        XCTAssertEqual(user.googleId, decoded.googleId)
        XCTAssertEqual(user.email, decoded.email)
        XCTAssertEqual(user.name, decoded.name)
        XCTAssertEqual(user.picture, decoded.picture)
    }
    
    func testUserInitialsTwoNames() {
        let user = User(id: UUID(), googleId: "1", email: "a@b.com", name: "John Doe")
        XCTAssertEqual(user.initials, "JD")
    }
    
    func testUserInitialsSingleName() {
        let user = User(id: UUID(), googleId: "2", email: "a@b.com", name: "Prince")
        XCTAssertEqual(user.initials, "PR")
    }
    
    func testUserInitialsThreeNames() {
        let user = User(id: UUID(), googleId: "3", email: "a@b.com", name: "John Paul Jones")
        XCTAssertEqual(user.initials, "JP")
    }
    
    func testUserDisplayName() {
        let user = User(id: UUID(), googleId: "4", email: "a@b.com", name: "John Doe")
        XCTAssertEqual(user.displayName, "John Doe")
    }
    
    func testUserJSONCodingKeys() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "googleId": "123",
            "email": "test@example.com",
            "name": "Test User",
            "picture": null,
            "createdAt": "2024-01-01T00:00:00Z",
            "updatedAt": "2024-01-01T00:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let user = try sharedJSONDecoder.decode(User.self, from: data)
        
        XCTAssertEqual(user.id.uuidString.uppercased(), "550E8400-E29B-41D4-A716-446655440000")
        XCTAssertEqual(user.googleId, "123")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertNil(user.picture)
    }
    
    func testSampleUserIsValid() {
        #if DEBUG
        let user = User.sample
        XCTAssertFalse(user.email.isEmpty)
        XCTAssertFalse(user.name.isEmpty)
        XCTAssertFalse(user.googleId.isEmpty)
        #endif
    }
}
