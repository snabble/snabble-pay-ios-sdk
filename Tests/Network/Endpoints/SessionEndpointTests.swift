//
//  SessionEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-19.
//

import XCTest
@testable import SnabblePayNetwork

final class SessionEndpointTests: XCTestCase {

    func testPostEndpoint() throws {
        let endpoint = Endpoints.Session.post()
        XCTAssertEqual(endpoint.path, "/apps/session")
        XCTAssertEqual(endpoint.method, .post(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testDeleteEndpoint() throws {
        let endpoint = Endpoints.Session.delete(id: "1")
        XCTAssertEqual(endpoint.path, "/apps/session/1")
        XCTAssertEqual(endpoint.method, .delete)
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testGetEndpoint() throws {
        let endpoint = Endpoints.Session.get(id: "1")
        XCTAssertEqual(endpoint.path, "/apps/session/1")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironmentStaging() throws {
        let endpoint1 = Endpoints.Session.post(onEnvironment: .staging)
        XCTAssertEqual(endpoint1.environment, .staging)

        let endpoint2 = Endpoints.Session.get(id: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint2.environment, .staging)

        let endpoint3 = Endpoints.Session.delete(id: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint3.environment, .staging)
    }

    func testEnvironmentDevelopment() throws {
        let endpoint1 = Endpoints.Session.post(onEnvironment: .development)
        XCTAssertEqual(endpoint1.environment, .development)

        let endpoint2 = Endpoints.Session.get(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint2.environment, .development)

        let endpoint3 = Endpoints.Session.delete(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint3.environment, .development)
    }

    func testDecodingAccountPost() throws {
        let jsonData = try loadResource(filename: "session-post", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Session.self, from: jsonData)
        XCTAssertEqual(instance.id.rawValue, "1")
        XCTAssertEqual(instance.token.rawValue, "3489f@asd2")
        XCTAssertEqual(instance.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:34:38Z"))
        XCTAssertEqual(instance.refreshAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.validUntil, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:44:38Z"))
        XCTAssertNil(instance.transaction)
    }

    func testDecodingAccountPostErrorDeclined() throws {
        let jsonData = try loadResource(filename: "session-post-error-declined", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Session.Error.self, from: jsonData)
        XCTAssertEqual(instance.reason, Session.Error.Reason.mandateDeclined)
        XCTAssertEqual(instance.message, "The user has to accept the mandate to start a session")
    }

    func testDecodingAccountPostError() throws {
        let jsonData = try loadResource(filename: "session-post-error-unknown", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Session.Error.self, from: jsonData)
        XCTAssertEqual(instance.reason, Session.Error.Reason.unknown)
        XCTAssertNil(instance.message)
    }

    func testDecodingAccountGet() throws {
        let jsonData = try loadResource(filename: "session-get", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Session.self, from: jsonData)
        XCTAssertEqual(instance.id.rawValue, "1")
        XCTAssertEqual(instance.token.rawValue, "token")
        XCTAssertEqual(instance.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.refreshAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:34:38Z"))
        XCTAssertEqual(instance.validUntil, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:44:38Z"))
        XCTAssertNotNil(instance.transaction)
        XCTAssertEqual(instance.transaction?.id, "1")
        XCTAssertEqual(instance.transaction?.state, .ongoing)
        XCTAssertEqual(instance.transaction?.amount, "3.99")
        XCTAssertEqual(instance.transaction?.currency, "EUR")
    }

    func testTransactionState() throws {
        var state: Transaction.State = .pending
        XCTAssertEqual(state.rawValue, "PENDING")
        state = .aborted
        XCTAssertEqual(state.rawValue, "ABORTED")
        state = .errored
        XCTAssertEqual(state.rawValue, "ERRORED")
        state = .failed
        XCTAssertEqual(state.rawValue, "FAILED")
        state = .ongoing
        XCTAssertEqual(state.rawValue, "ONGOING")
        state = .successful
        XCTAssertEqual(state.rawValue, "SUCCESSFUL")
    }
}
