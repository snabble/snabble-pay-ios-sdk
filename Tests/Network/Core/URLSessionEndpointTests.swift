//
//  URLSessionEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
import Combine
@testable import SnabblePayNetwork

final class URLSessionEndpointTests: XCTestCase {

    let resourceData = try! loadResource(filename: "register", withExtension: "json")
    let endpointRegister: Endpoint<App> = .register()
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
            XCTAssertNotNil(error as? URLError)
            XCTAssertEqual((error as! URLError).code, .unknown)
        }
    }

    func testDecodable() async throws {
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
        let dataTask = session.dataTask(for: endpointRegister) { result in
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

        let expectation = expectation(description: "register")
        let session = URLSession.mockSession
        let dataTask = session.dataTask(for: endpointRegister) { result in
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

    // MARK: - Data

    func testDataCombine() async throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [unowned self] request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/register")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [:]
            )!
            return (response, resourceData)
        }

        let endpoint: Endpoint<Data> = .init(path: "/apps/register", method: .get(nil))

        let expectation = expectation(description: "register")
        let session = URLSession.mockSession
        session.publisher(for: endpoint)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }
                expectation.fulfill()
            } receiveValue: { [unowned self] data in
                XCTAssertEqual(data, resourceData)
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDataCombineError() async throws {
        MockURLProtocol.error = URLError(.unknown)
        MockURLProtocol.requestHandler = nil

        let expectation = expectation(description: "register")
        let session = URLSession.mockSession
        session.publisher(for: endpointData)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error.code, .unknown)
                }
                expectation.fulfill()
            } receiveValue: { data in
                XCTAssertNil(data)
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testDataAsync() async throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [unowned self] request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/register")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [:]
            )!
            return (response, resourceData)
        }

        let session = URLSession.mockSession
        let response = try await session.data(for: endpointData)

        XCTAssertNotNil(response)
    }

    func testDataAsyncError() async throws {
        MockURLProtocol.error = URLError(.unknown)
        MockURLProtocol.requestHandler = nil

        do {
            let session = URLSession.mockSession
            let decodableObject = try await session.object(for: endpointData)
            XCTAssertNil(decodableObject)
        } catch {
            XCTAssertNotNil(error)
            XCTAssertNotNil(error as? URLError)
            XCTAssertEqual((error as! URLError).code, .unknown)
        }
    }

    func testData() async throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [unowned self] request in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/register")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [:]
            )!
            return (response, resourceData)
        }

        let session = URLSession.mockSession
        let expectation = expectation(description: "register")
        let dataTask = session.dataTask(for: endpointData) { result in
            switch result {
            case .failure(let error):
                XCTAssertNil(error)
            case .success(let response):
                XCTAssertNotNil(response)
            }
            expectation.fulfill()
        }

        dataTask.resume()

        wait(for: [expectation], timeout: 5.0)
    }

    func testDataError() async throws {
        MockURLProtocol.error = URLError(.unknown)
        MockURLProtocol.requestHandler = nil

        let session = URLSession.mockSession
        let expectation = expectation(description: "register")
        let dataTask = session.dataTask(for: endpointData) { result in
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
