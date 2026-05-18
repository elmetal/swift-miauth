import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import MiAuth

actor MockTransport: MiAuthTransport {
    private var requests: [URLRequest] = []
    private let data: Data
    private let statusCode: Int

    init(data: Data, statusCode: Int) {
        self.data = data
        self.statusCode = statusCode
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data, response)
    }

    func onlyRequest() throws -> URLRequest {
        try #require(requests.count == 1)
        return requests[0]
    }
}
