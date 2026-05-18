import Foundation

public struct MiAuthSessionID: Hashable, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        guard Self.isValid(rawValue) else {
            throw MiAuthError.invalidSessionID
        }
        self.rawValue = rawValue
    }

    private init(unchecked rawValue: String) {
        self.rawValue = rawValue
    }

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
