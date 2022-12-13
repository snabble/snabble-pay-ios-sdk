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

    func testDecodingCredentials() throws {
        let credentialsData = try loadResource(filename: "credentials", withExtension: "json")
        let credentials = try JSONDecoder().decode(Credentials.self, from: credentialsData)
        XCTAssertEqual(credentials.appIdentifier, "1l2z79uvnKU18hJ621hDti2Q1mckTs8633HFlUz7PCG1OalckFyKf/TzJlGcOUC4WPInc+RrKCAPLc0loJCtRw==")
        XCTAssertEqual(credentials.appSecret, "qPgwvqkVCFn+aFxljTClV7+kTe+18rOQ7Qrdp5YSethhi2X9Sp97UiDkAO3qzXgcdDi/+VazutfHxbA4SZKYWA==")
    }
}
