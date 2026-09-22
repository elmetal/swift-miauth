import Foundation
import Testing
@testable import MiAuth

@Test func clientPostsToCheckEndpointAndDecodesTokenAndUser() async throws {
    let transport = MockTransport(
        data: #"{"ok":true,"token":"issued-token","user":{"id":"9f","username":"ai","host":null,"name":"藍","avatarUrl":"https://misskey.example/ai.png"}}"#.data(using: .utf8)!,
        statusCode: 200
    )
    let client = MiAuthClient(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        transport: transport
    )

    let result = try await client.check(sessionID: try MiAuthSessionID("check-session"))
    let request = try await transport.onlyRequest()

    #expect(result.token == "issued-token")
    #expect(result.user == MiAuthUser(id: "9f", username: "ai", host: nil, name: "藍"))
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://misskey.example/api/miauth/check-session/check")
}

@Test func clientAcceptsTokenWithoutOkOrUser() async throws {
    let transport = MockTransport(
        data: #"{"token":"issued-token"}"#.data(using: .utf8)!,
        statusCode: 200
    )
    let client = MiAuthClient(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        transport: transport
    )

    let result = try await client.check(sessionID: try MiAuthSessionID("compat-session"))

    #expect(result.token == "issued-token")
    #expect(result.user == nil)
}

@Test func clientSurfacesNonSuccessHTTPResponses() async throws {
    let transport = MockTransport(
        data: #"{"error":{"code":"ACCESS_DENIED","message":"denied"}}"#.data(using: .utf8)!,
        statusCode: 403
    )
    let client = MiAuthClient(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        transport: transport
    )

    await #expect(throws: MiAuthError.nonSuccessHTTPResponse(statusCode: 403)) {
        _ = try await client.check(sessionID: try MiAuthSessionID("denied-session"))
    }
}

@Test func clientTreatsOkFalseAsAuthorizationNotCompletedOrDenied() async throws {
    let transport = MockTransport(
        data: #"{"ok":false}"#.data(using: .utf8)!,
        statusCode: 200
    )
    let client = MiAuthClient(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        transport: transport
    )

    await #expect(throws: MiAuthError.authorizationNotCompletedOrDenied) {
        _ = try await client.check(sessionID: try MiAuthSessionID("pending-session"))
    }
}

@Test func clientRejectsOkTrueWithoutToken() async throws {
    let transport = MockTransport(
        data: #"{"ok":true}"#.data(using: .utf8)!,
        statusCode: 200
    )
    let client = MiAuthClient(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        transport: transport
    )

    await #expect(throws: MiAuthError.invalidResponseBody) {
        _ = try await client.check(sessionID: try MiAuthSessionID("broken-session"))
    }
}

@Test func clientRejectsNonJSONBody() async throws {
    let transport = MockTransport(
        data: "<html>maintenance</html>".data(using: .utf8)!,
        statusCode: 200
    )
    let client = MiAuthClient(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        transport: transport
    )

    await #expect(throws: MiAuthError.invalidResponseBody) {
        _ = try await client.check(sessionID: try MiAuthSessionID("html-session"))
    }
}
