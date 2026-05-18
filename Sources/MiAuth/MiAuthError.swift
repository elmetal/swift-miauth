public enum MiAuthError: Error, Equatable, Sendable {
    case invalidInstanceURL
    case invalidCallbackURL
    case failedAuthorizationURLConstruction
    case invalidSessionID
    case networkFailure
    case nonSuccessHTTPResponse(statusCode: Int)
    case invalidResponseBody
    case authorizationNotCompletedOrDenied
}
