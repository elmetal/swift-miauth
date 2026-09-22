/// A permission string requested during MiAuth authorization.
///
/// Misskey-compatible instances may support additional permission values, so this type
/// accepts both known constants and custom raw strings.
public struct MiAuthPermission: RawRepresentable, Hashable, Sendable {
    /// The raw permission value sent to the instance.
    public let rawValue: String

    /// Creates a permission from a raw permission value.
    ///
    /// - Parameter rawValue: The permission string to request.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a permission from a raw permission value.
    ///
    /// - Parameter rawValue: The permission string to request.
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}

extension MiAuthPermission: ExpressibleByStringLiteral {
    /// Creates a permission from a string literal.
    ///
    /// - Parameter value: The permission string to request.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension MiAuthPermission {
    /// Permission to read account information.
    static let readAccount = MiAuthPermission("read:account")

    /// Permission to update account information.
    static let writeAccount = MiAuthPermission("write:account")

    /// Permission to read notes.
    ///
    /// - Warning: Misskey doesn't define a `read:notes` permission. Reading notes needs no
    ///   permission, and the authorization page silently drops unknown values. This constant
    ///   will be removed in a future release.
    @available(*, deprecated, message: "Misskey doesn't define read:notes; the authorization page ignores it. Reading notes needs no permission.")
    static let readNotes = MiAuthPermission("read:notes")

    /// Permission to create or update notes.
    static let writeNotes = MiAuthPermission("write:notes")

    /// Permission to read following relationships.
    static let readFollowing = MiAuthPermission("read:following")

    /// Permission to update following relationships.
    static let writeFollowing = MiAuthPermission("write:following")

    /// Permission to read drive files.
    static let readDrive = MiAuthPermission("read:drive")

    /// Permission to update drive files.
    static let writeDrive = MiAuthPermission("write:drive")

    /// Permission to read favorites.
    static let readFavorites = MiAuthPermission("read:favorites")

    /// Permission to update favorites.
    static let writeFavorites = MiAuthPermission("write:favorites")
}
