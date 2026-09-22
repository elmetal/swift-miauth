# swift-miauth

`swift-miauth` is a small Swift package for the protocol-level MiAuth flow used by Misskey-compatible servers.

It helps you:

- build MiAuth authorization URLs
- generate safe session IDs
- represent known and custom permissions
- validate MiAuth callback session values
- exchange an approved session for an access token and the authorizing user

It does not present browser UI, store tokens, manage accounts, or wrap the rest of the Misskey API.

## Installation

Add the package to your SwiftPM dependencies:

```swift
.package(url: "https://github.com/elmetal/swift-miauth.git", from: "0.1.0")
```

Then depend on the `MiAuth` product:

```swift
.product(name: "MiAuth", package: "swift-miauth")
```

## Minimal Example

```swift
import Foundation
import MiAuth

let instanceURL = URL(string: "https://misskey.example")!

let request = MiAuthRequest(
    instanceURL: instanceURL,
    appName: "MiAuth Example",
    iconURL: URL(string: "https://example.com/icon.png"),
    callbackURL: URL(string: "miauth-example://callback")!,
    permissions: [.readAccount, .writeNotes]
)

let authorizationURL = try request.authorizationURL()

// Open authorizationURL with the browser flow your app owns.
// After redirect, validate the callback URL:
let callback = try request.validateCallbackURL(callbackURLFromApp)

let client = MiAuthClient(instanceURL: instanceURL)
let result = try await client.check(sessionID: callback.sessionID)

let token = result.token
let username = result.user?.username
```

`check(sessionID:)` succeeds only once per session. Misskey marks the token as fetched on the first successful check, and every later check for the same session fails with `MiAuthError.authorizationNotCompletedOrDenied`. Store the token as soon as you receive it, and don't retry a check that already returned a token.

The same error is thrown while the user hasn't approved the request yet, and when the user denied it. The instance reports all three cases as `{"ok": false}`, so the package can't tell them apart.

## Custom Permissions

Misskey-compatible servers may add permission strings over time, so permissions are open-ended. Note that the authorization page silently drops permission values the instance doesn't know, so a typo or an unsupported permission results in a token without that permission rather than an error.

```swift
let permissions: [MiAuthPermission] = [
    .readAccount,
    MiAuthPermission("custom:capability"),
]
```

## Networking

`MiAuthClient` uses `URLSession` by default through `URLSessionMiAuthTransport`. Tests and apps can inject any `MiAuthTransport`:

```swift
let client = MiAuthClient(
    instanceURL: instanceURL,
    transport: myTransport
)
```

## Security Notes

- HTTPS instance URLs are required by default.
- HTTP can be allowed explicitly for local development with `allowsInsecureHTTP: true`.
- Session IDs are random version 4 UUIDs by default, as the MiAuth specification asks. `MiAuthSessionID.generate(byteCount:)` produces a longer hexadecimal identifier if you need one.
- Tokens are returned to the caller and are never persisted by this package.

## MiAuth Reference

The implemented flow follows the Misskey Hub MiAuth shape:

- authorization page: `https://{host}/miauth/{session}?name=...&icon=...&callback=...&permission=...`
- callback: the instance appends `session={session}` to the callback URL
- check endpoint: `POST https://{host}/api/miauth/{session}/check`
- check response: `{"ok": true, "token": "...", "user": {...}}` on success, `{"ok": false}` otherwise

See the official Misskey Hub documentation: <https://misskey-hub.net/en/docs/for-developers/api/token/miauth/>
