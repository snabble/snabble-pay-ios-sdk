//
//  EnvironmentTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
@testable import SnabblePayCore

final class EnvironmentTests: XCTestCase {
    func testDevelopmentHeaders() throws {
        let environment: Environment = .development
        XCTAssertEqual(environment.headers, ["Content-Type": "application/json"])
    }

    func testStagingHeaders() throws {
        let environment: Environment = .staging
        XCTAssertEqual(environment.headers, ["Content-Type": "application/json"])
    }

    func testProductionHeaders() throws {
        let environment: Environment = .production
        XCTAssertEqual(environment.headers, ["Content-Type": "application/json"])
    }

    func testDevelopmentBaseURL() throws {
        let environment: Environment = .development
        XCTAssertEqual(environment.baseURL, "https://api.snabble-testing.io")
    }

    func testStagingBaseURL() throws {
        let environment: Environment = .staging
        XCTAssertEqual(environment.baseURL, "https://api.snabble-staging.io")
    }

    func testProductionBaseURL() throws {
        let environment: Environment = .production
        XCTAssertEqual(environment.baseURL, "https://api.snabble.io")
    }
}
