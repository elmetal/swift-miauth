import Foundation

/// A session identifier used to correlate a MiAuth authorization flow.
public struct MiAuthSessionID: Hashable, Sendable {
    /// The raw session identifier value.
    public let rawValue: String

    /// Creates a session identifier from a raw value.
    ///
    /// - Parameter rawValue: The session identifier returned from, or sent to, an instance.
    /// - Throws: ``MiAuthError/invalidSessionID`` if the value is empty, too long, or contains unsupported characters.
    public init(_ rawValue: String) throws {
        guard Self.isValid(rawValue) else {
            throw MiAuthError.invalidSessionID
        }
        self.rawValue = rawValue
    }

    private init(unchecked rawValue: String) {
        self.rawValue = rawValue
    }

    /// Generates a random session identifier.
    ///
    /// - Parameter byteCount: The number of random bytes to encode as hexadecimal text.
    /// - Returns: A random session identifier.
    /// - Precondition: `byteCount` must be greater than `0`.
    public static func generate(byteCount: Int = 32) -> Self {
        precondition(byteCount > 0, "byteCount must be positive")

        var generator = SystemRandomNumberGenerator()
        let hex = (0..<byteCount)
            .map { _ in String(format: "%02x", UInt8.random(in: .min ... .max, using: &generator)) }
            .joined()
        return Self(unchecked: hex)
    }

    private static func isValid(_ rawValue: String) -> Bool {
        guard !rawValue.isEmpty, rawValue.count <= 128 else {
            return false
        }

        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return rawValue.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
}
