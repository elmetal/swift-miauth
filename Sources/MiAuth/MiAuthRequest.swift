import Foundation

/// A description of a MiAuth authorization request.
public struct MiAuthRequest: Hashable, Sendable {
    /// The Misskey-compatible instance that presents the authorization page.
    public let instanceURL: URL

    /// The application name to display on the authorization page.
    public let appName: String

    /// The URL of an icon image to display on the authorization page.
    public let iconURL: URL?

    /// The URL the instance opens after authorization completes.
    public let callbackURL: URL?

    /// The permissions to request from the user.
    ///
    /// Duplicates are removed when building the authorization URL, because Misskey rejects
    /// them at approval time.
    public let permissions: [MiAuthPermission]

    /// The session identifier that correlates authorization and check requests.
    public let sessionID: MiAuthSessionID

    /// A Boolean value that indicates whether the request accepts HTTP instance URLs.
    public let allowsInsecureHTTP: Bool

    /// Creates a MiAuth authorization request.
    ///
    /// - Parameters:
    ///   - instanceURL: The base URL of a Misskey-compatible instance.
    ///   - appName: The application name to display on the authorization page.
    ///   - iconURL: The URL of an icon image to display on the authorization page.
    ///   - callbackURL: The URL the instance opens after authorization completes.
    ///   - permissions: The permissions to request from the user.
    ///   - sessionID: The session identifier to use for the flow.
    ///   - allowsInsecureHTTP: A Boolean value that allows HTTP instance URLs when set to `true`.
    public init(
        instanceURL: URL,
        appName: String,
        iconURL: URL? = nil,
        callbackURL: URL? = nil,
        permissions: [MiAuthPermission] = [],
        sessionID: MiAuthSessionID = .generate(),
        allowsInsecureHTTP: Bool = false
    ) {
        self.instanceURL = instanceURL
        self.appName = appName
        self.iconURL = iconURL
        self.callbackURL = callbackURL
        self.permissions = permissions
        self.sessionID = sessionID
        self.allowsInsecureHTTP = allowsInsecureHTTP
    }

    /// Creates the authorization URL to open in a browser.
    ///
    /// The callback URL must have a scheme, and the scheme must not be one the Misskey
    /// authorization page refuses to redirect to: `javascript`, `file`, `data`, `mailto`,
    /// `tel`, or `vbscript`. Rejecting those here surfaces the mistake before the user
    /// reaches the authorization page.
    ///
    /// - Returns: A URL that starts the MiAuth authorization flow.
    /// - Throws: A ``MiAuthError`` value if the instance or callback URL is invalid.
    public func authorizationURL() throws -> URL {
        var components = try normalizedMiAuthInstanceComponents(
            instanceURL: instanceURL,
            allowsInsecureHTTP: allowsInsecureHTTP
        )
        components.path = "/miauth/\(sessionID.rawValue)"

        var queryItems = [URLQueryItem(name: "name", value: appName)]
        if let iconURL {
            queryItems.append(URLQueryItem(name: "icon", value: iconURL.absoluteString))
        }
        if let callbackURL {
            _ = try callbackComponents(from: callbackURL)
            queryItems.append(URLQueryItem(name: "callback", value: callbackURL.absoluteString))
        }
        if !permissions.isEmpty {
            // Misskey's `miauth/gen-token` rejects duplicate permissions (`uniqueItems: true`),
            // and that failure surfaces only after the user taps approve. Drop duplicates here,
            // keeping the first occurrence so the authorization page lists them in order.
            var seen = Set<MiAuthPermission>()
            let unique = permissions.filter { seen.insert($0).inserted }
            let permission = unique.map(\.rawValue).joined(separator: ",")
            queryItems.append(URLQueryItem(name: "permission", value: permission))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw MiAuthError.failedAuthorizationURLConstruction
        }
        return url
    }

    /// Validates a callback URL and returns its MiAuth session information.
    ///
    /// The callback must match the request's callback URL and include a `session` query
    /// item that matches ``sessionID``.
    ///
    /// - Parameter url: The callback URL received by your app.
    /// - Returns: The validated MiAuth callback.
    /// - Throws: A ``MiAuthError`` value if the callback doesn't match the request.
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

    /// Schemes the Misskey authorization page refuses to redirect to.
    private static let blockedCallbackSchemes: Set<String> = [
        "javascript", "file", "data", "mailto", "tel", "vbscript",
    ]

    private func callbackComponents(from url: URL) throws -> URLComponents {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme?.lowercased(),
              !Self.blockedCallbackSchemes.contains(scheme)
        else {
            throw MiAuthError.invalidCallbackURL
        }
        return components
    }
}
