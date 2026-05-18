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
    /// - Parameter sessionID: The session identifier to check.
    /// - Returns: A check result that contains the access token.
    /// - Throws: A ``MiAuthError`` value if the request fails or the instance returns an invalid response.
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

        do {
            return try JSONDecoder().decode(MiAuthCheckResult.self, from: data)
        } catch {
            if let failure = try? JSONDecoder().decode(MiAuthFailureResponse.self, from: data),
               failure.hasFailure {
                throw MiAuthError.authorizationNotCompletedOrDenied
            }
            throw MiAuthError.invalidResponseBody
        }
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
public struct MiAuthCheckResult: Decodable, Hashable, Sendable {
    /// The access token issued by the instance.
    public let token: String

    /// Creates a check result with the specified token.
    ///
    /// - Parameter token: The access token issued by the instance.
    public init(token: String) {
        self.token = token
    }
}

private struct MiAuthFailureResponse: Decodable {
    let error: Failure?
    let code: String?
    let message: String?

    struct Failure: Decodable {
        let code: String?
        let message: String?
    }

    var hasFailure: Bool {
        error != nil || code != nil || message != nil
    }
}
