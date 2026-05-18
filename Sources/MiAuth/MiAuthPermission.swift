public struct MiAuthPermission: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}

extension MiAuthPermission: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension MiAuthPermission {
    static let readAccount = MiAuthPermission("read:account")
    static let writeAccount = MiAuthPermission("write:account")
    static let readNotes = MiAuthPermission("read:notes")
    static let writeNotes = MiAuthPermission("write:notes")
    static let readFollowing = MiAuthPermission("read:following")
    static let writeFollowing = MiAuthPermission("write:following")
    static let readDrive = MiAuthPermission("read:drive")
    static let writeDrive = MiAuthPermission("write:drive")
    static let readFavorites = MiAuthPermission("read:favorites")
    static let writeFavorites = MiAuthPermission("write:favorites")
}
