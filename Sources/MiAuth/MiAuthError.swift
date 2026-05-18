/// An error that can occur while creating or completing a MiAuth flow.
public enum MiAuthError: Error, Equatable, Sendable {
    /// The instance URL is missing required components or contains unsupported components.
    case invalidInstanceURL

    /// The callback URL is missing required components or doesn't match the returned callback.
    case invalidCallbackURL

    /// The authorization URL couldn't be created from the request values.
    case failedAuthorizationURLConstruction

    /// The session identifier contains unsupported characters or has an invalid length.
    case invalidSessionID

    /// A network request failed before receiving a usable response.
    case networkFailure

    /// The instance returned an HTTP response outside the success range.
    ///
    /// - Parameter statusCode: The status code from the HTTP response.
    case nonSuccessHTTPResponse(statusCode: Int)

    /// The response body couldn't be decoded as a supported MiAuth response.
    case invalidResponseBody

    /// The user hasn't completed the authorization flow, or denied the request.
    case authorizationNotCompletedOrDenied
}
