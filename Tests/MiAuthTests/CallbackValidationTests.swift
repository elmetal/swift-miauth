import Foundation
import Testing
@testable import MiAuth

@Test func callbackValidationExtractsAndMatchesSession() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        appName: "MiAuth Example",
        callbackURL: URL(string: "miauth-example://callback?source=login")!,
        sessionID: try MiAuthSessionID("callback-session")
    )

    let callback = try #require(URL(string: "miauth-example://callback?source=login&session=callback-session"))
    let result = try request.validateCallbackURL(callback)
    let expectedSessionID = try MiAuthSessionID("callback-session")

    #expect(result.sessionID == expectedSessionID)
}

@Test func callbackValidationRejectsWrongSessionOrRoute() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        appName: "MiAuth Example",
        callbackURL: URL(string: "miauth-example://callback")!,
        sessionID: try MiAuthSessionID("expected-session")
    )

    #expect(throws: MiAuthError.authorizationNotCompletedOrDenied) {
        try request.validateCallbackURL(try #require(URL(string: "miauth-example://callback?session=other-session")))
    }

    #expect(throws: MiAuthError.invalidCallbackURL) {
        try request.validateCallbackURL(try #require(URL(string: "miauth-example://other?session=expected-session")))
    }
}

@Test func callbackValidationIgnoresSchemeAndHostCase() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        appName: "MiAuth Example",
        callbackURL: try #require(URL(string: "https://App.Example/Callback")),
        sessionID: try MiAuthSessionID("case-session")
    )

    // WHATWG URL lowercases scheme and host on redirect; the path keeps its case.
    let callback = try #require(URL(string: "https://app.example/Callback?session=case-session"))
    let result = try request.validateCallbackURL(callback)

    #expect(result.sessionID == (try MiAuthSessionID("case-session")))

    #expect(throws: MiAuthError.invalidCallbackURL) {
        try request.validateCallbackURL(try #require(URL(string: "https://app.example/callback?session=case-session")))
    }
}
