//
//  URLSession+Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Combine

private extension URLResponse {
    func verify(with data: Data) throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw HTTPError.unknownResponse(self)
        }
        guard httpResponse.httpStatusCode.responseType == .success else {
            let endpointError = try? JSONDecoder().decode(Endpoints.Error.self, from: data)
            throw HTTPError.invalidResponse(httpResponse.httpStatusCode, endpointError)
        }
    }
}

private extension Publisher where Output == (data: Data, response: URLResponse), Failure == any Error {
    func tryVerifyResponse() -> AnyPublisher<Output, Failure> {
        tryMap { (data, response) throws -> Output in
            try response.verify(with: data)
            return (data, response)
        }
        .eraseToAnyPublisher()
    }
}

@available(iOS 13, *)
extension URLSession {
    func publisher<Response: Decodable>(
        for endpoint: Endpoint<Response>
    ) -> AnyPublisher<Response, Swift.Error> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .mapError({ $0 as Swift.Error })
            .tryVerifyResponse()
            .map(\.data)
            .decode(type: Response.self, decoder: endpoint.jsonDecoder)
            .eraseToAnyPublisher()
    }
}
