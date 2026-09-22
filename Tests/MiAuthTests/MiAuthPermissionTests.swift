import Testing
@testable import MiAuth

/// The non-administrative entries of `permissions` in misskey-js `consts.ts`.
private let misskeyNonAdminPermissions: Set<String> = [
    "read:account", "write:account",
    "read:blocks", "write:blocks",
    "read:drive", "write:drive",
    "read:favorites", "write:favorites",
    "read:following", "write:following",
    "read:messaging", "write:messaging",
    "read:mutes", "write:mutes",
    "write:notes",
    "read:notifications", "write:notifications",
    "read:reactions", "write:reactions",
    "write:votes",
    "read:pages", "write:pages",
    "write:page-likes", "read:page-likes",
    "read:user-groups", "write:user-groups",
    "read:channels", "write:channels",
    "read:gallery", "write:gallery",
    "read:gallery-likes", "write:gallery-likes",
    "read:flash", "write:flash",
    "read:flash-likes", "write:flash-likes",
    "write:invite-codes", "read:invite-codes",
    "write:clip-favorite", "read:clip-favorite",
    "read:federation",
    "write:report-abuse",
    "write:chat", "read:chat",
]

private let allPermissions: [MiAuthPermission] = [
    .account.read, .account.write,
    .notes.write,
    .reactions.read, .reactions.write,
    .votes.write,
    .favorites.read, .favorites.write,
    .clipFavorite.read, .clipFavorite.write,
    .following.read, .following.write,
    .blocks.read, .blocks.write,
    .mutes.read, .mutes.write,
    .reportAbuse.write,
    .notifications.read, .notifications.write,
    .drive.read, .drive.write,
    .chat.read, .chat.write,
    .messaging.read, .messaging.write,
    .userGroups.read, .userGroups.write,
    .pages.read, .pages.write,
    .pageLikes.read, .pageLikes.write,
    .gallery.read, .gallery.write,
    .galleryLikes.read, .galleryLikes.write,
    .flash.read, .flash.write,
    .flashLikes.read, .flashLikes.write,
    .channels.read, .channels.write,
    .federation.read,
    .inviteCodes.read, .inviteCodes.write,
]

@Test func resourcePermissionsMatchMisskeyNonAdminList() {
    let rawValues = Set(allPermissions.map(\.rawValue))

    #expect(rawValues == misskeyNonAdminPermissions)
    #expect(allPermissions.count == misskeyNonAdminPermissions.count, "no duplicate permissions")
}

@Test func resourcePermissionsUseReadAndWritePrefixes() {
    #expect(MiAuthPermission.account.read.rawValue == "read:account")
    #expect(MiAuthPermission.account.write.rawValue == "write:account")
    #expect(MiAuthPermission.pageLikes.read.rawValue == "read:page-likes")
    #expect(MiAuthPermission.notes.write.rawValue == "write:notes")
}

@Test func stringLiteralsAndRawValuesProduceEqualPermissions() {
    let literal: MiAuthPermission = "read:admin:meta"

    #expect(literal == MiAuthPermission("read:admin:meta"))
    #expect(literal == MiAuthPermission(rawValue: "read:admin:meta"))
    #expect(MiAuthPermission("read:account") == .account.read)
}
