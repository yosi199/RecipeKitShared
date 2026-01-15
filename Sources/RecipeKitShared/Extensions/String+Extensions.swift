import Foundation

extension String {
    /// Check if string is empty or contains only whitespace
    public var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Trimmed version of the string
    public var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Check if string is a valid email format (basic validation)
    public var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        guard let regex = try? NSRegularExpression(pattern: emailRegex, options: []) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}
