import Foundation

func normalizedMiAuthInstanceComponents(
    instanceURL: URL,
    allowsInsecureHTTP: Bool
) throws -> URLComponents {
    guard var components = URLComponents(url: instanceURL, resolvingAgainstBaseURL: false),
          let scheme = components.scheme?.lowercased(),
          components.host != nil,
          components.user == nil,
          components.password == nil,
          components.query == nil,
          components.fragment == nil
    else {
        throw MiAuthError.invalidInstanceURL
    }

    guard scheme == "https" || (allowsInsecureHTTP && scheme == "http") else {
        throw MiAuthError.invalidInstanceURL
    }

    guard components.path.isEmpty || components.path == "/" else {
        throw MiAuthError.invalidInstanceURL
    }

    components.scheme = scheme
    components.path = ""
    components.queryItems = nil
    components.fragment = nil
    return components
}
