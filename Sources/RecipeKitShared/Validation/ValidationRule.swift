import Foundation

/// Protocol for defining validation rules
public protocol ValidationRule {
    associatedtype Value
    func validate(_ value: Value) throws
}

// MARK: - Common Validation Rules

/// Validates that a string is not empty
public struct NotEmptyRule: ValidationRule {
    private let fieldName: String
    
    public init(fieldName: String) {
        self.fieldName = fieldName
    }
    
    public func validate(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ValidationError.fieldRequired("\(fieldName) is required")
        }
    }
}

/// Validates that a value is within a range
public struct RangeRule<T: Comparable>: ValidationRule {
    private let fieldName: String
    private let min: T
    private let max: T
    
    public init(fieldName: String, min: T, max: T) {
        self.fieldName = fieldName
        self.min = min
        self.max = max
    }
    
    public func validate(_ value: T) throws {
        guard value >= min && value <= max else {
            throw ValidationError.invalidValue("\(fieldName) must be between \(min) and \(max)")
        }
    }
}
