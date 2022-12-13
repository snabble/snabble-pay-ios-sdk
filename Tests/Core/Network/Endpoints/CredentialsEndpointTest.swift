//
//  CredentialsEndpointTest.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
@testable import SnabblePayCore

final class CredentialsEndpointTest: XCTestCase {
    func testEndpoint() throws {
        let endpoint = Endpoint<Any>.credentials()
        XCTAssertEqual(endpoint.path, "/apps/credentials")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoint<Any>.credentials(onEnvironment: .staging)
        XCTAssertEqual(endpoint.path, "/apps/credentials")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoint<Any>.credentials(onEnvironment: .development)
        XCTAssertEqual(endpoint.path, "/apps/credentials")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .development)
    }
}
