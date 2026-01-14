import Foundation

extension Date {
    /// Format date for display in iOS app (e.g., "Jan 14, 2024 at 10:30 AM")
    public var displayFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Relative time string (e.g., "2 hours ago", "3 days ago")
    public var relativeFormat: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Short date format (e.g., "Jan 14, 2024")
    public var shortDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
