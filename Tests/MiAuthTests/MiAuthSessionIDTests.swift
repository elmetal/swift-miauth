import Foundation
import Testing
@testable import MiAuth

@Test func generatedSessionIDsAreLowercaseUUIDsAndUnique() throws {
    let first = MiAuthSessionID.generate()
    let second = MiAuthSessionID.generate()

    #expect(first != second)
    #expect(first.rawValue.count == 36)
    #expect(first.rawValue == first.rawValue.lowercased())
    #expect(UUID(uuidString: first.rawValue) != nil)
}

@Test func sessionIDFromUUIDUsesLowercaseHyphenatedForm() throws {
    let uuid = try #require(UUID(uuidString: "0F1E2D3C-4B5A-6978-8796-A5B4C3D2E1F0"))
    let sessionID = MiAuthSessionID(uuid: uuid)

    #expect(sessionID.rawValue == "0f1e2d3c-4b5a-6978-8796-a5b4c3d2e1f0")
}

@Test func hexSessionIDsUseSafeURLCharactersAndAreUnique() throws {
    let first = MiAuthSessionID.generate(byteCount: 32)
    let second = MiAuthSessionID.generate(byteCount: 32)
    let allowed = CharacterSet(charactersIn: "0123456789abcdef")

    #expect(first.rawValue.count == 64)
    #expect(second.rawValue.count == 64)
    #expect(first != second)
    #expect(first.rawValue.unicodeScalars.allSatisfy { allowed.contains($0) })
}

@Test func invalidSessionIDsAreRejected() {
    #expect(throws: MiAuthError.invalidSessionID) {
        _ = try MiAuthSessionID("not/a/session")
    }

    #expect(throws: MiAuthError.invalidSessionID) {
        _ = try MiAuthSessionID("")
    }
}
