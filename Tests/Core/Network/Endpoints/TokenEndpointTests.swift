//
//  TokenEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
@testable import SnabblePayCore

final class TokenEndpointTests: XCTestCase {
    func testEndpoint() throws {
        let endpoint = Endpoint<Any>.token(withAppIdentifier: "random_app_identifier", appSecret: "random_app_secret")
        XCTAssertEqual(endpoint.path, "/apps/token")
        XCTAssertEqual(endpoint.method, .get(
            [
               .init(name: "grant_type", value: "client_credentials"),
               .init(name: "client_id", value: "random_app_identifier"),
               .init(name: "client_secret", value: "random_app_secret"),
               .init(name: "scope", value: "all")
            ]
        ))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoint<Any>.token(withAppIdentifier: "random_app_identifier", appSecret: "random_app_secret", onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoint<Any>.token(withAppIdentifier: "random_app_identifier", appSecret: "random_app_secret", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testDecodingCredentials() throws {
        let data = try loadResource(filename: "token", withExtension: "json")
        let decodedObject = try JSONDecoder().decode(Token.self, from: data)
        XCTAssertEqual(decodedObject.accessToken, "ZMNBLHLDNJM6JI-LSW8X-Q")
        XCTAssertEqual(decodedObject.expiresIn, 7200)
        XCTAssertEqual(decodedObject.scope, .all)
        XCTAssertEqual(decodedObject.type, .bearer)
    }
}
