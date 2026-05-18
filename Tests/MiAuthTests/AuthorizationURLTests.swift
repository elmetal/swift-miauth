import Foundation
import Testing
@testable import MiAuth

@Test func authorizationURLContainsMiAuthPathAndEncodedQuery() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        appName: "keyring",
        callbackURL: URL(string: "keyring://miauth/callback")!,
        permissions: [.readAccount, .writeNotes],
        sessionID: try MiAuthSessionID("fixed-session")
    )

    let url = try request.authorizationURL()
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let queryItems = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

    #expect(components.scheme == "https")
    #expect(components.host == "misskey.example")
    #expect(components.path == "/miauth/fixed-session")
    #expect(queryItems["name"] == "keyring")
    #expect(queryItems["callback"] == "keyring://miauth/callback")
    #expect(queryItems["permission"] == "read:account,write:notes")
}

@Test func authorizationURLSupportsCustomPermissions() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example/")),
        appName: "custom",
        permissions: [.readAccount, MiAuthPermission("custom:capability")],
        sessionID: try MiAuthSessionID("session-custom")
    )

    let url = try request.authorizationURL()
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let permission = components.queryItems?.first { $0.name == "permission" }?.value

    #expect(permission == "read:account,custom:capability")
}

@Test func invalidInstanceURLsAreRejected() throws {
    let ftpRequest = MiAuthRequest(
        instanceURL: try #require(URL(string: "ftp://misskey.example")),
        appName: "bad",
        sessionID: try MiAuthSessionID("session")
    )

    #expect(throws: MiAuthError.invalidInstanceURL) {
        _ = try ftpRequest.authorizationURL()
    }

    let pathRequest = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example/base")),
        appName: "bad",
        sessionID: try MiAuthSessionID("session")
    )

    #expect(throws: MiAuthError.invalidInstanceURL) {
        _ = try pathRequest.authorizationURL()
    }
}
