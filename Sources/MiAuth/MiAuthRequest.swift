import Foundation

public struct MiAuthRequest: Hashable, Sendable {
    public let instanceURL: URL
    public let appName: String
    public let callbackURL: URL?
    public let permissions: [MiAuthPermission]
    public let sessionID: MiAuthSessionID
    public let allowsInsecureHTTP: Bool

    public init(
        instanceURL: URL,
        appName: String,
        callbackURL: URL? = nil,
        permissions: [MiAuthPermission] = [],
        sessionID: MiAuthSessionID = .generate(),
        allowsInsecureHTTP: Bool = false
    ) {
        self.instanceURL = instanceURL
        self.appName = appName
        self.callbackURL = callbackURL
        self.permissions = permissions
        self.sessionID = sessionID
        self.allowsInsecureHTTP = allowsInsecureHTTP
    }

    public func authorizationURL() throws -> URL {
        var components = try normalizedMiAuthInstanceComponents(
            instanceURL: instanceURL,
            allowsInsecureHTTP: allowsInsecureHTTP
        )
        components.path = "/miauth/\(sessionID.rawValue)"

        var queryItems = [URLQueryItem(name: "name", value: appName)]
        if let callbackURL {
            guard callbackURL.scheme != nil else {
                throw MiAuthError.invalidCallbackURL
            }
            queryItems.append(URLQueryItem(name: "callback", value: callbackURL.absoluteString))
        }
        if !permissions.isEmpty {
            let permission = permissions.map(\.rawValue).joined(separator: ",")
            queryItems.append(URLQueryItem(name: "permission", value: permission))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw MiAuthError.failedAuthorizationURLConstruction
        }
        return url
    }

    public func validateCallbackURL(_ url: URL) throws -> MiAuthCallback {
        guard let callbackURL else {
            throw MiAuthError.invalidCallbackURL
        }

        let expected = try callbackComponents(from: callbackURL)
        let actual = try callbackComponents(from: url)

        guard expected.scheme == actual.scheme,
              expected.host == actual.host,
              expected.port == actual.port,
              expected.path == actual.path
        else {
            throw MiAuthError.invalidCallbackURL
        }

        let actualItems = actual.queryItems ?? []
        for expectedItem in expected.queryItems ?? [] where expectedItem.name != "session" {
            guard actualItems.contains(where: { $0.name == expectedItem.name && $0.value == expectedItem.value }) else {
                throw MiAuthError.invalidCallbackURL
            }
        }

        guard let rawSession = actualItems.first(where: { $0.name == "session" })?.value,
              let callbackSessionID = try? MiAuthSessionID(rawSession)
        else {
            throw MiAuthError.authorizationNotCompletedOrDenied
        }

        guard callbackSessionID == sessionID else {
            throw MiAuthError.authorizationNotCompletedOrDenied
        }

        return MiAuthCallback(sessionID: callbackSessionID)
    }

    private func callbackComponents(from url: URL) throws -> URLComponents {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme != nil
        else {
            throw MiAuthError.invalidCallbackURL
        }
        return components
    }
}
