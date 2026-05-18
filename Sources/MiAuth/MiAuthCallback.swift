public struct MiAuthCallback: Hashable, Sendable {
    public let sessionID: MiAuthSessionID

    public init(sessionID: MiAuthSessionID) {
        self.sessionID = sessionID
    }
}
