//
//  URLSession+Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Combine

enum HTTPError: Equatable {
    case invalidResponse(statusCode: HTTPStatusCode)
    case unknownResponse(URLResponse)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let statusCode):
            return "Error: \(statusCode)"
        case .unknownResponse(let response):
            return "Error: unknown \(response)"
        }
    }
}

private extension URLResponse {
    func verify() throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw HTTPError.unknownResponse(self)
        }
        guard httpResponse.httpStatusCode.responseType == .success else {
            throw HTTPError.invalidResponse(statusCode: httpResponse.httpStatusCode)
        }
    }
}

private extension Publisher where Output == (data: Data, response: URLResponse), Failure == any Error {
    func tryVerifyResponse() -> AnyPublisher<Output, Failure> {
        tryMap { (data, response) throws -> Output in
            try response.verify()
            return (data, response)
        }
        .eraseToAnyPublisher()
    }
}

@available(iOS 13, *)
extension URLSession {
    func publisher(for endpoint: Endpoint<Data>) -> AnyPublisher<Data, Swift.Error> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .mapError({ $0 as Swift.Error })
            .tryVerifyResponse()
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func publisher<Response: Decodable>(
        for endpoint: Endpoint<Response>,
        using decoder: JSONDecoder = .init()
    ) -> AnyPublisher<Response, Swift.Error> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .mapError({ $0 as Swift.Error })
            .tryVerifyResponse()
            .map(\.data)
            .decode(type: Response.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

@available(iOS 15.0, *)
extension URLSession {
    func data(for endpoint: Endpoint<Data>) async throws -> Data {
        let (data, response) = try await self.data(for: endpoint.urlRequest)
        try response.verify()
        return data
    }

    func object<Response: Decodable>(
        for endpoint: Endpoint<Response>,
        using decoder: JSONDecoder = .init()
    ) async throws -> Response {
        let (data, response) = try await self.data(for: endpoint.urlRequest)
        try response.verify()
        return try decoder.decode(Response.self, from: data)
    }
}
