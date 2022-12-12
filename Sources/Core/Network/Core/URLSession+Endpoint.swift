//
//  URLSession+Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Combine

extension URLSession {
    enum Error: Swift.Error {
        case networking(URLError)
        case decoding(Swift.Error)
        case unknown(String)
    }

    @available(iOS 13, watchOS 6, OSX 10.15, *)
    func publisher(for endpoint: any Endpoint<Data>) -> AnyPublisher<Data, Swift.Error> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .mapError(Error.networking)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    @available(iOS 13, watchOS 6, OSX 10.15, *)
        func publisher<Response: Decodable>(
            for endpoint: any Endpoint<Response>,
            using decoder: JSONDecoder = .init()
        ) -> AnyPublisher<Response, Swift.Error> {
            dataTaskPublisher(for: endpoint.urlRequest)
                .mapError(Error.networking)
                .map(\.data)
                .decode(type: Response.self, decoder: decoder)
                .mapError(Error.decoding)
                .eraseToAnyPublisher()
        }
}

extension URLSession {
    func dataTask(
        for endpoint: any Endpoint<Data>,
        completionHandler: @escaping (Swift.Result<Data, Swift.Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: endpoint.urlRequest) { data, _, error in
            do {
                if let error = error {
                    throw error
                }

                guard let data = data else {
                    throw URLSession.Error.unknown("no data")
                }

                completionHandler(.success(data))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    func dataTask<Response: Decodable>(
        for endpoint: any Endpoint<Response>,
        using decoder: JSONDecoder = .init(),
        completionHandler: @escaping (Swift.Result<Response, Swift.Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: endpoint.urlRequest) { data, _, error in
            do {
                if let error = error {
                    throw error
                }

                guard let data = data else {
                    throw URLSession.Error.unknown("no data")
                }

                let response = try decoder.decode(Response.self, from: data)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}
