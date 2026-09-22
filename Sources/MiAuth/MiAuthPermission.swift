/// A permission string requested during MiAuth authorization.
///
/// Misskey permissions take the form `read:{resource}` or `write:{resource}`. Use the
/// resource properties to build them, such as `.account.read` or `.notes.write`. Only the
/// combinations Misskey defines exist, so `.notes.read` doesn't compile.
///
/// Misskey-compatible instances may support additional permission values, and Misskey's
/// administrative permissions (`read:admin:*`, `write:admin:*`) aren't modeled here, so this
/// type also accepts raw strings.
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

// MARK: - Resources

extension MiAuthPermission {
    /// A resource that MiAuth permissions refer to.
    ///
    /// Conforming types describe one resource segment, such as `account` in `read:account`.
    /// They gain ``Readable/read`` by also conforming to ``Readable``, and ``Writable/write``
    /// by conforming to ``Writable``.
    public protocol Resource: Sendable {
        /// The resource segment of the permission string.
        var name: String { get }
    }

    /// A resource that Misskey allows reading.
    public protocol Readable: Resource {}

    /// A resource that Misskey allows writing.
    public protocol Writable: Resource {}
}

public extension MiAuthPermission.Readable {
    /// The `read:{resource}` permission for this resource.
    var read: MiAuthPermission {
        MiAuthPermission("read:\(name)")
    }
}

public extension MiAuthPermission.Writable {
    /// The `write:{resource}` permission for this resource.
    var write: MiAuthPermission {
        MiAuthPermission("write:\(name)")
    }
}

/// The non-administrative resources defined by Misskey.
///
/// These mirror the `permissions` list in `misskey-js`.
public extension MiAuthPermission {
    // MARK: Account

    /// The account resource, for `read:account` and `write:account`.
    struct Account: Readable, Writable {
        public let name = "account"
    }

    /// The account resource.
    static let account = Account()

    // MARK: Notes

    /// The notes resource, for `write:notes`.
    ///
    /// Reading notes needs no permission, so Misskey defines no `read:notes`.
    struct Notes: Writable {
        public let name = "notes"
    }

    /// The notes resource.
    static let notes = Notes()

    /// The reactions resource, for `read:reactions` and `write:reactions`.
    struct Reactions: Readable, Writable {
        public let name = "reactions"
    }

    /// The reactions resource.
    static let reactions = Reactions()

    /// The poll votes resource, for `write:votes`.
    struct Votes: Writable {
        public let name = "votes"
    }

    /// The poll votes resource.
    static let votes = Votes()

    /// The favorites resource, for `read:favorites` and `write:favorites`.
    struct Favorites: Readable, Writable {
        public let name = "favorites"
    }

    /// The favorites resource.
    static let favorites = Favorites()

    /// The clip favorites resource, for `read:clip-favorite` and `write:clip-favorite`.
    struct ClipFavorite: Readable, Writable {
        public let name = "clip-favorite"
    }

    /// The clip favorites resource.
    static let clipFavorite = ClipFavorite()

    // MARK: Relationships

    /// The following resource, for `read:following` and `write:following`.
    struct Following: Readable, Writable {
        public let name = "following"
    }

    /// The following resource.
    static let following = Following()

    /// The blocks resource, for `read:blocks` and `write:blocks`.
    struct Blocks: Readable, Writable {
        public let name = "blocks"
    }

    /// The blocks resource.
    static let blocks = Blocks()

    /// The mutes resource, for `read:mutes` and `write:mutes`.
    struct Mutes: Readable, Writable {
        public let name = "mutes"
    }

    /// The mutes resource.
    static let mutes = Mutes()

    /// The abuse report resource, for `write:report-abuse`.
    struct ReportAbuse: Writable {
        public let name = "report-abuse"
    }

    /// The abuse report resource.
    static let reportAbuse = ReportAbuse()

    // MARK: Notifications

    /// The notifications resource, for `read:notifications` and `write:notifications`.
    struct Notifications: Readable, Writable {
        public let name = "notifications"
    }

    /// The notifications resource.
    static let notifications = Notifications()

    // MARK: Drive

    /// The drive resource, for `read:drive` and `write:drive`.
    struct Drive: Readable, Writable {
        public let name = "drive"
    }

    /// The drive resource.
    static let drive = Drive()

    // MARK: Chat and messaging

    /// The chat resource, for `read:chat` and `write:chat`.
    struct Chat: Readable, Writable {
        public let name = "chat"
    }

    /// The chat resource.
    static let chat = Chat()

    /// The legacy direct messaging resource, for `read:messaging` and `write:messaging`.
    ///
    /// Misskey removed the messaging feature in version 13. The permission remains in the
    /// list for forks that still provide it.
    struct Messaging: Readable, Writable {
        public let name = "messaging"
    }

    /// The legacy direct messaging resource.
    static let messaging = Messaging()

    /// The legacy user groups resource, for `read:user-groups` and `write:user-groups`.
    ///
    /// Misskey removed user groups in version 13. The permission remains in the list for
    /// forks that still provide them.
    struct UserGroups: Readable, Writable {
        public let name = "user-groups"
    }

    /// The legacy user groups resource.
    static let userGroups = UserGroups()

    // MARK: Pages, gallery, and Play

    /// The pages resource, for `read:pages` and `write:pages`.
    struct Pages: Readable, Writable {
        public let name = "pages"
    }

    /// The pages resource.
    static let pages = Pages()

    /// The page likes resource, for `read:page-likes` and `write:page-likes`.
    struct PageLikes: Readable, Writable {
        public let name = "page-likes"
    }

    /// The page likes resource.
    static let pageLikes = PageLikes()

    /// The gallery resource, for `read:gallery` and `write:gallery`.
    struct Gallery: Readable, Writable {
        public let name = "gallery"
    }

    /// The gallery resource.
    static let gallery = Gallery()

    /// The gallery likes resource, for `read:gallery-likes` and `write:gallery-likes`.
    struct GalleryLikes: Readable, Writable {
        public let name = "gallery-likes"
    }

    /// The gallery likes resource.
    static let galleryLikes = GalleryLikes()

    /// The Play scripts resource, for `read:flash` and `write:flash`.
    struct Flash: Readable, Writable {
        public let name = "flash"
    }

    /// The Play scripts resource.
    static let flash = Flash()

    /// The Play likes resource, for `read:flash-likes` and `write:flash-likes`.
    struct FlashLikes: Readable, Writable {
        public let name = "flash-likes"
    }

    /// The Play likes resource.
    static let flashLikes = FlashLikes()

    // MARK: Channels and federation

    /// The channels resource, for `read:channels` and `write:channels`.
    struct Channels: Readable, Writable {
        public let name = "channels"
    }

    /// The channels resource.
    static let channels = Channels()

    /// The federation resource, for `read:federation`.
    struct Federation: Readable {
        public let name = "federation"
    }

    /// The federation resource.
    static let federation = Federation()

    // MARK: Invitations

    /// The invite codes resource, for `read:invite-codes` and `write:invite-codes`.
    struct InviteCodes: Readable, Writable {
        public let name = "invite-codes"
    }

    /// The invite codes resource.
    static let inviteCodes = InviteCodes()
}
