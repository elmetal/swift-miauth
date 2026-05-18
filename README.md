# swift-miauth

`swift-miauth` is a small Swift package for the protocol-level MiAuth flow used by Misskey-compatible servers.

It helps you:

- build MiAuth authorization URLs
- generate safe session IDs
- represent known and custom permissions
- validate MiAuth callback session values
- exchange an approved session for an access token

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
    appName: "keyring",
    callbackURL: URL(string: "keyring://miauth/callback")!,
    permissions: [.readAccount, .writeNotes]
)

let authorizationURL = try request.authorizationURL()

// Open authorizationURL with the browser flow your app owns.
// After redirect, validate the callback URL:
let callback = try request.validateCallbackURL(callbackURLFromApp)

let client = MiAuthClient(instanceURL: instanceURL)
let result = try await client.check(sessionID: callback.sessionID)

let token = result.token
```

## Custom Permissions

Misskey-compatible servers may add permission strings over time, so permissions are open-ended:

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
- Session IDs are generated from system randomness and encoded as 64 hex characters by default.
- Tokens are returned to the caller and are never persisted by this package.

## MiAuth Reference

The implemented flow follows the Misskey Hub MiAuth shape:

- authorization page: `https://{host}/miauth/{session}`
- check endpoint: `POST https://{host}/api/miauth/{session}/check`

See the official Misskey Hub documentation: <https://misskey-hub.net/en/docs/for-developers/api/token/miauth/>
