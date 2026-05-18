import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A type that performs MiAuth network requests.
public protocol MiAuthTransport: Sendable {
    /// Performs a URL request and returns its data and response.
    ///
    /// - Parameter request: The URL request to perform.
    /// - Returns: The data and response returned by the server.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// A MiAuth transport backed by `URLSession`.
public struct URLSessionMiAuthTransport: MiAuthTransport, @unchecked Sendable {
    /// The URL session used to perform requests.
    public let session: URLSession

    /// Creates a transport backed by the specified URL session.
    ///
    /// - Parameter session: The URL session to use when performing requests.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Performs a URL request with the underlying URL session.
    ///
    /// - Parameter request: The URL request to perform.
    /// - Returns: The data and response returned by the server.
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let data, let response else {
                    continuation.resume(throwing: MiAuthError.invalidResponseBody)
                    return
                }

                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}
