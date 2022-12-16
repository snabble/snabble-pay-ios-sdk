//
//  URLSession+Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Combine

@available(iOS 13, *)
extension URLSession {
    func publisher(for endpoint: Endpoint<Data>) -> AnyPublisher<Data, URLError> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func publisher<Response: Decodable>(
        for endpoint: Endpoint<Response>,
        using decoder: JSONDecoder = .init()
    ) -> AnyPublisher<Response, Swift.Error> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .map(\.data)
            .decode(type: Response.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

extension URLSession {
    func dataTask(
        for endpoint: Endpoint<Data>,
        completionHandler: @escaping (Swift.Result<Data, Swift.Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: endpoint.urlRequest) { data, _, error in
            do {
                if let error = error {
                    throw error
                }

                guard let data = data else {
                    throw URLError(.badServerResponse)
                }

                completionHandler(.success(data))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    func dataTask<Response: Decodable>(
        for endpoint: Endpoint<Response>,
        using decoder: JSONDecoder = .init(),
        completionHandler: @escaping (Swift.Result<Response, Swift.Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: endpoint.urlRequest) { data, _, error in
            do {
                if let error = error {
                    throw error
                }

                guard let data = data else {
                    throw URLError(.badServerResponse)
                }

                let response = try decoder.decode(Response.self, from: data)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}

@available(iOS 15.0, *)
extension URLSession {
    func data(for endpoint: Endpoint<Data>) async throws -> Data {
        let (data, _) = try await self.data(for: endpoint.urlRequest)
        return data
    }

    func object<Response: Decodable>(
        for endpoint: Endpoint<Response>,
        using decoder: JSONDecoder = .init()
    ) async throws -> Response {
        let (data, _) = try await self.data(for: endpoint.urlRequest)
        return try decoder.decode(Response.self, from: data)
    }
}
