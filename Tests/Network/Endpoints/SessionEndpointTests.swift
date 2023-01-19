//
//  SessionEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-19.
//

import XCTest
@testable import SnabblePayNetwork

final class SessionEndpointTests: XCTestCase {

    func testEndpoint() throws {
        let endpoint = Endpoints.session()
        XCTAssertEqual(endpoint.path, "/apps/sessions")
        XCTAssertEqual(endpoint.method, .post(nil))
        XCTAssertNil(endpoint.headerFields)
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironmentStaging() throws {
        let endpoint = Endpoints.session(onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)
    }

    func testEnvironmentDevelopment() throws {
        let endpoint = Endpoints.session(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testDecodingAccount() throws {
        let jsonData = try loadResource(filename: "session-post", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Session.self, from: jsonData)
        XCTAssertEqual(instance.id.rawValue, "1")
        XCTAssertEqual(instance.token.rawValue, "3489f@asd2")
    }
}
