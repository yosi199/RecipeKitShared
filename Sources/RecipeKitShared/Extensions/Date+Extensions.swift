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
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .none
        let now = Date()
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .weekOfYear, .month, .year], from: self, to: now)
        
        let interval = now.timeIntervalSince(self)
        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let weeks = days / 7
        let months = days / 30
        let years = days / 365
        
        if seconds < 60 {
            return seconds <= 1 ? "just now" : "\(seconds) seconds ago"
        } else if minutes < 60 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else if hours < 24 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if days < 7 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if weeks < 4 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if months < 12 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }
    }
    
    /// Short date format (e.g., "Jan 14, 2024")
    public var shortDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
