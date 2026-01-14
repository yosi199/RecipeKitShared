import Foundation

extension UUID {
    /// Create UUID from string safely, returning nil if invalid
    public static func from(_ string: String) -> UUID? {
        UUID(uuidString: string)
    }
    
    /// Create a zero UUID for testing/placeholder purposes
    public static var zero: UUID {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
}
