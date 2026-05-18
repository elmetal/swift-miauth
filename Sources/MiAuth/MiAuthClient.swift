import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct MiAuthClient: Sendable {
    public let instanceURL: URL
    public let transport: any MiAuthTransport
    public let allowsInsecureHTTP: Bool

    public init(
        instanceURL: URL,
        transport: any MiAuthTransport = URLSessionMiAuthTransport(),
        allowsInsecureHTTP: Bool = false
    ) {
        self.instanceURL = instanceURL
        self.transport = transport
        self.allowsInsecureHTTP = allowsInsecureHTTP
    }

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

public struct MiAuthCheckResult: Decodable, Hashable, Sendable {
    public let token: String

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
