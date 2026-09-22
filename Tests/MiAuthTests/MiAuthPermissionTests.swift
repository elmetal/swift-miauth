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

private let allConstants: [MiAuthPermission] = [
    .readAccount, .writeAccount,
    .writeNotes, .readReactions, .writeReactions, .writeVotes,
    .readFavorites, .writeFavorites, .readClipFavorite, .writeClipFavorite,
    .readFollowing, .writeFollowing, .readBlocks, .writeBlocks, .readMutes, .writeMutes,
    .writeReportAbuse,
    .readNotifications, .writeNotifications,
    .readDrive, .writeDrive,
    .readChat, .writeChat, .readMessaging, .writeMessaging, .readUserGroups, .writeUserGroups,
    .readPages, .writePages, .readPageLikes, .writePageLikes,
    .readGallery, .writeGallery, .readGalleryLikes, .writeGalleryLikes,
    .readFlash, .writeFlash, .readFlashLikes, .writeFlashLikes,
    .readChannels, .writeChannels, .readFederation,
    .readInviteCodes, .writeInviteCodes,
]

@Test func permissionConstantsMatchMisskeyNonAdminList() {
    let rawValues = Set(allConstants.map(\.rawValue))

    #expect(rawValues == misskeyNonAdminPermissions)
    #expect(allConstants.count == misskeyNonAdminPermissions.count, "no duplicate constants")
}

@Test func stringLiteralsAndRawValuesProduceEqualPermissions() {
    let literal: MiAuthPermission = "read:admin:meta"

    #expect(literal == MiAuthPermission("read:admin:meta"))
    #expect(literal == MiAuthPermission(rawValue: "read:admin:meta"))
}
