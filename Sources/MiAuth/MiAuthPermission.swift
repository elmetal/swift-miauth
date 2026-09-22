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

/// Permissions defined by Misskey.
///
/// These constants mirror the non-administrative entries of the `permissions` list in
/// `misskey-js`. Administrative permissions (`read:admin:*`, `write:admin:*`) and
/// permissions added by forks can be passed as raw strings.
public extension MiAuthPermission {
    // MARK: Account

    /// Permission to read account information.
    static let readAccount = MiAuthPermission("read:account")

    /// Permission to update account information.
    static let writeAccount = MiAuthPermission("write:account")

    // MARK: Notes

    /// Permission to read notes.
    ///
    /// - Warning: Misskey doesn't define a `read:notes` permission. Reading notes needs no
    ///   permission, and the authorization page silently drops unknown values. This constant
    ///   will be removed in a future release.
    @available(*, deprecated, message: "Misskey doesn't define read:notes; the authorization page ignores it. Reading notes needs no permission.")
    static let readNotes = MiAuthPermission("read:notes")

    /// Permission to create or delete notes.
    static let writeNotes = MiAuthPermission("write:notes")

    /// Permission to read reactions.
    static let readReactions = MiAuthPermission("read:reactions")

    /// Permission to add or remove reactions.
    static let writeReactions = MiAuthPermission("write:reactions")

    /// Permission to vote in polls.
    static let writeVotes = MiAuthPermission("write:votes")

    /// Permission to read favorites.
    static let readFavorites = MiAuthPermission("read:favorites")

    /// Permission to update favorites.
    static let writeFavorites = MiAuthPermission("write:favorites")

    /// Permission to read favorited clips.
    static let readClipFavorite = MiAuthPermission("read:clip-favorite")

    /// Permission to favorite or unfavorite clips.
    static let writeClipFavorite = MiAuthPermission("write:clip-favorite")

    // MARK: Relationships

    /// Permission to read following relationships.
    static let readFollowing = MiAuthPermission("read:following")

    /// Permission to update following relationships.
    static let writeFollowing = MiAuthPermission("write:following")

    /// Permission to read blocked users.
    static let readBlocks = MiAuthPermission("read:blocks")

    /// Permission to block or unblock users.
    static let writeBlocks = MiAuthPermission("write:blocks")

    /// Permission to read muted users.
    static let readMutes = MiAuthPermission("read:mutes")

    /// Permission to mute or unmute users.
    static let writeMutes = MiAuthPermission("write:mutes")

    /// Permission to report abuse.
    static let writeReportAbuse = MiAuthPermission("write:report-abuse")

    // MARK: Notifications

    /// Permission to read notifications.
    static let readNotifications = MiAuthPermission("read:notifications")

    /// Permission to update notifications.
    static let writeNotifications = MiAuthPermission("write:notifications")

    // MARK: Drive

    /// Permission to read drive files.
    static let readDrive = MiAuthPermission("read:drive")

    /// Permission to update drive files.
    static let writeDrive = MiAuthPermission("write:drive")

    // MARK: Chat and messaging

    /// Permission to read chat messages.
    static let readChat = MiAuthPermission("read:chat")

    /// Permission to send chat messages.
    static let writeChat = MiAuthPermission("write:chat")

    /// Permission to read legacy direct messages.
    ///
    /// Misskey removed the messaging feature in version 13. The permission remains in the
    /// list for forks that still provide it.
    static let readMessaging = MiAuthPermission("read:messaging")

    /// Permission to send legacy direct messages.
    ///
    /// Misskey removed the messaging feature in version 13. The permission remains in the
    /// list for forks that still provide it.
    static let writeMessaging = MiAuthPermission("write:messaging")

    /// Permission to read legacy user groups.
    ///
    /// Misskey removed user groups in version 13. The permission remains in the list for
    /// forks that still provide them.
    static let readUserGroups = MiAuthPermission("read:user-groups")

    /// Permission to update legacy user groups.
    ///
    /// Misskey removed user groups in version 13. The permission remains in the list for
    /// forks that still provide them.
    static let writeUserGroups = MiAuthPermission("write:user-groups")

    // MARK: Pages, gallery, and Play

    /// Permission to read pages.
    static let readPages = MiAuthPermission("read:pages")

    /// Permission to create or update pages.
    static let writePages = MiAuthPermission("write:pages")

    /// Permission to read page likes.
    static let readPageLikes = MiAuthPermission("read:page-likes")

    /// Permission to like or unlike pages.
    static let writePageLikes = MiAuthPermission("write:page-likes")

    /// Permission to read gallery posts.
    static let readGallery = MiAuthPermission("read:gallery")

    /// Permission to create or update gallery posts.
    static let writeGallery = MiAuthPermission("write:gallery")

    /// Permission to read gallery likes.
    static let readGalleryLikes = MiAuthPermission("read:gallery-likes")

    /// Permission to like or unlike gallery posts.
    static let writeGalleryLikes = MiAuthPermission("write:gallery-likes")

    /// Permission to read Play scripts.
    static let readFlash = MiAuthPermission("read:flash")

    /// Permission to create or update Play scripts.
    static let writeFlash = MiAuthPermission("write:flash")

    /// Permission to read Play likes.
    static let readFlashLikes = MiAuthPermission("read:flash-likes")

    /// Permission to like or unlike Play scripts.
    static let writeFlashLikes = MiAuthPermission("write:flash-likes")

    // MARK: Channels and federation

    /// Permission to read channels.
    static let readChannels = MiAuthPermission("read:channels")

    /// Permission to create or update channels.
    static let writeChannels = MiAuthPermission("write:channels")

    /// Permission to read federation information.
    static let readFederation = MiAuthPermission("read:federation")

    // MARK: Invitations

    /// Permission to read invite codes.
    static let readInviteCodes = MiAuthPermission("read:invite-codes")

    /// Permission to create invite codes.
    static let writeInviteCodes = MiAuthPermission("write:invite-codes")
}
