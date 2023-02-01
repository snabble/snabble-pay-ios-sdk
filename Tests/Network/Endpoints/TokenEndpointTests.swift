//
//  TokenEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
@testable import SnabblePayNetwork
import TestHelper

final class TokenEndpointTests: XCTestCase {
    func testEndpoint() throws {
        let endpoint = Endpoints.Token.get(withAppIdentifier: "random_app_identifier", appSecret: "random_app_secret")
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
        XCTAssertEqual(endpoint.urlRequest.url?.absoluteString, "https://payment.snabble.io/apps/token?client_id=random_app_identifier&client_secret=random_app_secret&grant_type=client_credentials&scope=all")
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.Token.get(withAppIdentifier: "random_app_identifier", appSecret: "random_app_secret", onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.Token.get(withAppIdentifier: "random_app_identifier", appSecret: "random_app_secret", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testDecodingCredentials() throws {
        let data = try loadResource(inBundle: .module, filename: "token", withExtension: "json")
        let decodedObject = try TestingDefaults.jsonDecoder.decode(Token.self, from: data)
        XCTAssertEqual(decodedObject.accessToken, "ZMNBLHLDNJM6JI-LSW8X-Q")
        XCTAssertEqual(decodedObject.expiresAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T12:53:55+02:00"))
        XCTAssertEqual(decodedObject.scope, .all)
        XCTAssertEqual(decodedObject.type, .bearer)
    }

    func testTokenIsValid() throws {
        let tokenIsInvalid = Token(accessToken: "123", expiresAt: Date.init(timeIntervalSinceNow: -5), scope: .all, type: .bearer)
        XCTAssertFalse(tokenIsInvalid.isValid())

        let tokenIsValid = Token(accessToken: "1234", expiresAt: Date.init(timeIntervalSinceNow: 5), scope: .all, type: .bearer)
        XCTAssertTrue(tokenIsValid.isValid())
    }
}
