import Foundation

/// Validation errors for form inputs
public enum ValidationError: Error, LocalizedError, Sendable {
    case fieldRequired(String)
    case fieldTooShort(String)
    case fieldTooLong(String)
    case invalidValue(String)
    case invalidFormat(String)
    
    public var errorDescription: String? {
        switch self {
        case .fieldRequired(let message),
             .fieldTooShort(let message),
             .fieldTooLong(let message),
             .invalidValue(let message),
             .invalidFormat(let message):
            return message
        }
    }
}
