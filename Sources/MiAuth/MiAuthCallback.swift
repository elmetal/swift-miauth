/// A validated callback returned from a MiAuth authorization flow.
public struct MiAuthCallback: Hashable, Sendable {
    /// The session identifier included in the callback URL.
    public let sessionID: MiAuthSessionID

    /// Creates a MiAuth callback with the specified session identifier.
    ///
    /// - Parameter sessionID: The session identifier included in the callback URL.
    public init(sessionID: MiAuthSessionID) {
        self.sessionID = sessionID
    }
}
