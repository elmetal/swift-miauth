import Foundation
import Testing
@testable import MiAuth

@Test func authorizationURLContainsMiAuthPathAndEncodedQuery() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        appName: "MiAuth Example",
        iconURL: URL(string: "https://app.example/icon.png"),
        callbackURL: URL(string: "miauth-example://callback")!,
        permissions: [.account.read, .notes.write],
        sessionID: try MiAuthSessionID("fixed-session")
    )

    let url = try request.authorizationURL()
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let queryItems = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

    #expect(components.scheme == "https")
    #expect(components.host == "misskey.example")
    #expect(components.path == "/miauth/fixed-session")
    #expect(queryItems["name"] == "MiAuth Example")
    #expect(queryItems["icon"] == "https://app.example/icon.png")
    #expect(queryItems["callback"] == "miauth-example://callback")
    #expect(queryItems["permission"] == "read:account,write:notes")
}

@Test func authorizationURLSupportsCustomPermissions() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example/")),
        appName: "custom",
        permissions: [.account.read, MiAuthPermission("custom:capability")],
        sessionID: try MiAuthSessionID("session-custom")
    )

    let url = try request.authorizationURL()
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let permission = components.queryItems?.first { $0.name == "permission" }?.value
    let names = components.queryItems?.map(\.name) ?? []

    #expect(permission == "read:account,custom:capability")
    #expect(!names.contains("icon"))
    #expect(!names.contains("callback"))
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

@Test func blockedCallbackSchemesAreRejected() throws {
    let blocked = [
        "javascript:alert(1)",
        "file:///etc/hosts",
        "data:text/html,hi",
        "mailto:user@example.com",
        "tel:+810000000000",
        "vbscript:msgbox",
        "JAVASCRIPT:alert(1)",
    ]

    for raw in blocked {
        let request = MiAuthRequest(
            instanceURL: try #require(URL(string: "https://misskey.example")),
            appName: "bad",
            callbackURL: try #require(URL(string: raw)),
            sessionID: try MiAuthSessionID("session")
        )

        #expect(throws: MiAuthError.invalidCallbackURL, "\(raw) should be rejected") {
            _ = try request.authorizationURL()
        }
    }
}

@Test func callbackWithoutSchemeIsRejected() throws {
    let request = MiAuthRequest(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        appName: "bad",
        callbackURL: try #require(URL(string: "callback")),
        sessionID: try MiAuthSessionID("session")
    )

    #expect(throws: MiAuthError.invalidCallbackURL) {
        _ = try request.authorizationURL()
    }
}
