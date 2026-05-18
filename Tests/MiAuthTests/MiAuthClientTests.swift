import Foundation
import Testing
@testable import MiAuth

@Test func clientPostsToCheckEndpointAndDecodesToken() async throws {
    let transport = MockTransport(
        data: #"{"token":"issued-token","user":{"id":"9f","username":"ai"}}"#.data(using: .utf8)!,
        statusCode: 200
    )
    let client = MiAuthClient(
        instanceURL: try #require(URL(string: "https://misskey.example")),
        transport: transport
    )

    let result = try await client.check(sessionID: try MiAuthSessionID("check-session"))
    let request = try await transport.onlyRequest()

    #expect(result.token == "issued-token")
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://misskey.example/api/miauth/check-session/check")
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

@Test func clientTreatsMissingTokenAsAuthorizationNotCompleted() async throws {
    let transport = MockTransport(
        data: #"{"error":{"code":"PENDING","message":"not approved"}}"#.data(using: .utf8)!,
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
