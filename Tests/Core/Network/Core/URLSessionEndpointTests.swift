//
//  URLSessionEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
import Combine
@testable import SnabblePayCore

final class URLSessionEndpointTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    // MARK: - Decodable

    func testDecodableCombine() async throws {
        let data = try loadResource(filename: "credentials", withExtension: "json")
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/credentials")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }

        let endpoint: Endpoint<Credentials> = .credentials()
        let session = URLSession.mockSession

        let expectation = expectation(description: "credentials")
        session.publisher(for: endpoint)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }
                expectation.fulfill()
            } receiveValue: { credentials in
                XCTAssertNotNil(credentials)
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDecodableCombineError() async throws {
        MockURLProtocol.error = URLError(.unknown)
        MockURLProtocol.requestHandler = nil

        let endpoint: Endpoint<Credentials> = .credentials()
        let session = URLSession.mockSession

        let expectation = expectation(description: "credentials")
        session.publisher(for: endpoint)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertNotNil(error as? URLError)
                    XCTAssertEqual((error as! URLError).code, .unknown)
                }
                expectation.fulfill()
            } receiveValue: { credentials in
                XCTAssertNil(credentials)
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDecodableAsync() async throws {
        let data = try loadResource(filename: "credentials", withExtension: "json")
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/credentials")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }

        let endpoint: Endpoint<Credentials> = .credentials()
        let session = URLSession.mockSession

        let decodableObject = try await session.object(for: endpoint)

        XCTAssertNotNil(decodableObject)
    }

    func testDecodableAsyncError() async throws {
        MockURLProtocol.error = URLError(.unknown)
        MockURLProtocol.requestHandler = nil

        let endpoint: Endpoint<Credentials> = .credentials()
        let session = URLSession.mockSession

        do {
            let decodableObject = try await session.object(for: endpoint)
            XCTAssertNil(decodableObject)
        } catch {
            XCTAssertNotNil(error)
            XCTAssertNotNil(error as? URLError)
            XCTAssertEqual((error as! URLError).code, .unknown)
        }
    }

    func testDecodable() async throws {
        let data = try loadResource(filename: "credentials", withExtension: "json")
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/credentials")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }

        let endpoint: Endpoint<Credentials> = .credentials()
        let session = URLSession.mockSession

        let expectation = expectation(description: "credentials")
        let dataTask = session.dataTask(for: endpoint) { result in
            switch result {
            case .failure(let error):
                XCTAssertNil(error)
            case .success(let credentials):
                XCTAssertNotNil(credentials)
            }
            expectation.fulfill()
        }

        dataTask.resume()

        wait(for: [expectation], timeout: 5.0)
    }

    func testDecodableError() async throws {
        MockURLProtocol.error = URLError(.unknown)
        MockURLProtocol.requestHandler = nil

        let endpoint: Endpoint<Credentials> = .credentials()
        let session = URLSession.mockSession

        let expectation = expectation(description: "credentials")
        let dataTask = session.dataTask(for: endpoint) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertNotNil(error as? URLError)
                XCTAssertEqual((error as! URLError).code, .unknown)
            case .success(let credentials):
                XCTAssertNil(credentials)
            }
            expectation.fulfill()
        }

        dataTask.resume()

        wait(for: [expectation], timeout: 5.0)
    }
}
