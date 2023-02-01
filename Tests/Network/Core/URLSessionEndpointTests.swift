//
//  URLSessionEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
import Combine
@testable import SnabblePayNetwork
import TestHelper

final class URLSessionEndpointTests: XCTestCase {

    let resourceData = try! loadResource(inBundle: .module, filename: "register", withExtension: "json")
    let endpointRegister: Endpoint<App> = Endpoints.Register.post(apiKeyValue: "123456")
    let endpointData: Endpoint<Data> = .init(path: "/apps/register", method: .get(nil))
    var cancellables = Set<AnyCancellable>()

    // MARK: - Decodable

    func testDecodableCombine() async throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [unowned self] request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/register")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, resourceData)
        }

        let expectation = expectation(description: "register")
        let session = URLSession.mockSession
        session.publisher(for: endpointRegister)
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

        let expectation = expectation(description: "register")
        let session = URLSession.mockSession
        session.publisher(for: endpointRegister)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertNotNil(error is URLError)
                }
                expectation.fulfill()
            } receiveValue: { credentials in
                XCTAssertNil(credentials)
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDecodableCombineInvalidResponse() async throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [unowned self] request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/register")!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, resourceData)
        }

        let expectation = expectation(description: "register")
        let session = URLSession.mockSession
        session.publisher(for: endpointRegister)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertTrue(error is HTTPError)
                }
                expectation.fulfill()
            } receiveValue: { credentials in
                XCTAssertNil(credentials)
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDecodableAsync() async throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [unowned self] request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/register")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, resourceData)
        }

        let session = URLSession.mockSession
        let decodableObject = try await session.object(for: endpointRegister)

        XCTAssertNotNil(decodableObject)
    }

    func testDecodableAsyncError() async throws {
        MockURLProtocol.error = URLError(.unknown)
        MockURLProtocol.requestHandler = nil

        do {
            let session = URLSession.mockSession
            let decodableObject = try await session.object(for: endpointRegister)
            XCTAssertNil(decodableObject)
        } catch {
            XCTAssertNotNil(error)
            XCTAssertNotNil(error is URLError)
        }
    }

    func testDecodableAsyncInvalidResponse() async throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [unowned self] request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/register")!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, resourceData)
        }

        do {
            let session = URLSession.mockSession
            let decodableObject = try await session.object(for: endpointRegister)
            XCTAssertNil(decodableObject)
        } catch {
            XCTAssertNotNil(error)
            XCTAssertNotNil(error is HTTPError)
        }
    }
}
