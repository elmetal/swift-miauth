import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A client that exchanges approved MiAuth sessions for access tokens.
public struct MiAuthClient: Sendable {
    /// The Misskey-compatible instance that receives check requests.
    public let instanceURL: URL

    /// The transport the client uses to perform network requests.
    public let transport: any MiAuthTransport

    /// A Boolean value that indicates whether the client accepts HTTP instance URLs.
    public let allowsInsecureHTTP: Bool

    /// Creates a MiAuth client for the specified instance.
    ///
    /// - Parameters:
    ///   - instanceURL: The base URL of a Misskey-compatible instance.
    ///   - transport: The transport to use when sending requests.
    ///   - allowsInsecureHTTP: A Boolean value that allows HTTP instance URLs when set to `true`.
    public init(
        instanceURL: URL,
        transport: any MiAuthTransport = URLSessionMiAuthTransport(),
        allowsInsecureHTTP: Bool = false
    ) {
        self.instanceURL = instanceURL
        self.transport = transport
        self.allowsInsecureHTTP = allowsInsecureHTTP
    }

    /// Checks an approved MiAuth session and returns the resulting access token.
    ///
    /// The instance answers with HTTP 200 in both outcomes. A successful check returns
    /// `{"ok": true, "token": ..., "user": ...}`. A check for a session that hasn't been
    /// approved yet, was denied, or was already checked returns `{"ok": false}`, which this
    /// method reports as ``MiAuthError/authorizationNotCompletedOrDenied``.
    ///
    /// - Important: A session can be checked successfully only once. The instance marks the
    ///   token as fetched on the first successful check, and every later check for the same
    ///   session fails with ``MiAuthError/authorizationNotCompletedOrDenied``. Store the
    ///   returned token immediately, and don't retry a check that already succeeded.
    ///
    /// - Parameter sessionID: The session identifier to check.
    /// - Returns: A check result that contains the access token and the authorizing user.
    /// - Throws: A ``MiAuthError`` value if the request fails, the user hasn't approved the
    ///   session, or the instance returns an invalid response.
    public func check(sessionID: MiAuthSessionID) async throws -> MiAuthCheckResult {
        let request = try checkRequest(sessionID: sessionID)
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await transport.data(for: request)
        } catch {
            throw MiAuthError.networkFailure
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MiAuthError.invalidResponseBody
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw MiAuthError.nonSuccessHTTPResponse(statusCode: httpResponse.statusCode)
        }

        let envelope: MiAuthCheckResponse
        do {
            envelope = try JSONDecoder().decode(MiAuthCheckResponse.self, from: data)
        } catch {
            throw MiAuthError.invalidResponseBody
        }

        if envelope.ok == false {
            throw MiAuthError.authorizationNotCompletedOrDenied
        }

        guard let token = envelope.token else {
            throw MiAuthError.invalidResponseBody
        }

        return MiAuthCheckResult(token: token, user: envelope.user)
    }

    /// Creates the URL request for checking a MiAuth session.
    ///
    /// Use this method to inspect or perform the check request yourself.
    ///
    /// - Parameter sessionID: The session identifier to include in the request path.
    /// - Returns: A configured `POST` request for the instance check endpoint.
    /// - Throws: A ``MiAuthError`` value if the instance URL can't be used to create a request.
    public func checkRequest(sessionID: MiAuthSessionID) throws -> URLRequest {
        var components = try normalizedMiAuthInstanceComponents(
            instanceURL: instanceURL,
            allowsInsecureHTTP: allowsInsecureHTTP
        )
        components.path = "/api/miauth/\(sessionID.rawValue)/check"

        guard let url = components.url else {
            throw MiAuthError.failedAuthorizationURLConstruction
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        return request
    }
}

/// The response from a successful MiAuth check request.
public struct MiAuthCheckResult: Hashable, Sendable {
    /// The access token issued by the instance.
    public let token: String

    /// The user who approved the authorization request.
    ///
    /// Misskey always includes this value. It's optional so that Misskey-compatible
    /// instances that omit it can still complete the flow.
    public let user: MiAuthUser?

    /// Creates a check result with the specified token and user.
    ///
    /// - Parameters:
    ///   - token: The access token issued by the instance.
    ///   - user: The user who approved the authorization request.
    public init(token: String, user: MiAuthUser? = nil) {
        self.token = token
        self.user = user
    }
}

/// The user information returned by a MiAuth check request.
///
/// Misskey returns a detailed user object. This type decodes the stable identifying fields
/// and ignores the rest, so it stays compatible across instance versions.
public struct MiAuthUser: Decodable, Hashable, Sendable {
    /// The user's identifier on the instance.
    public let id: String

    /// The user's username, without the leading `@` or host.
    public let username: String

    /// The host of the user's home instance, or `nil` for local users.
    public let host: String?

    /// The user's display name, if set.
    public let name: String?

    /// Creates a user with the specified values.
    ///
    /// - Parameters:
    ///   - id: The user's identifier on the instance.
    ///   - username: The user's username.
    ///   - host: The host of the user's home instance, or `nil` for local users.
    ///   - name: The user's display name, if set.
    public init(id: String, username: String, host: String? = nil, name: String? = nil) {
        self.id = id
        self.username = username
        self.host = host
        self.name = name
    }
}

private struct MiAuthCheckResponse: Decodable {
    let ok: Bool?
    let token: String?
    let user: MiAuthUser?
}
