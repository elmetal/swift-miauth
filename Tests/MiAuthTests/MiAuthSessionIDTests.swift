import Foundation
import Testing
@testable import MiAuth

@Test func generatedSessionIDsUseSafeURLCharactersAndAreUnique() throws {
    let first = MiAuthSessionID.generate()
    let second = MiAuthSessionID.generate()
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
