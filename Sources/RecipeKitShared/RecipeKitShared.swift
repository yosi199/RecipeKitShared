import Foundation

// MARK: - Shared JSON Coders

/// Shared JSON decoder configured with ISO8601 date strategy
public let sharedJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

/// Shared JSON encoder configured with ISO8601 date strategy
public let sharedJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
}()
