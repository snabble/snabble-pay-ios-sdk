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
        let endpoint = Endpoints.Token.get(withCredentials: .init(identifier: "random_app_identifier", secret: "random_app_secret"))
        XCTAssertEqual(endpoint.path, "/apps/token")
        let jsonObject = [
            "grant_type": "client_credentials",
            "client_id": "random_app_identifier",
            "client_secret": "random_app_secret",
            "scope": Token.Scope.all.rawValue
        ]
        switch endpoint.method {
        case .post(let data):
            XCTAssertNotNil(data)
            XCTAssertEqual(jsonObject, try JSONSerialization.jsonObject(with: data!) as? [String: String])
        default:
            XCTFail("wrong method")
        }
        XCTAssertEqual(endpoint.environment, .production)
        XCTAssertEqual(endpoint.headerFields, ["Content-Type": "application/x-www-form-urlencoded"])
        XCTAssertNoThrow(try endpoint.urlRequest())
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://payment.snabble.io/apps/token")
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.Token.get(withCredentials: .init(identifier: "random_app_identifier", secret: "random_app_secret"), onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.Token.get(withCredentials: .init(identifier: "random_app_identifier", secret: "random_app_secret"), onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testDecodingCredentials() throws {
        let data = try loadResource(inBundle: .module, filename: "token", withExtension: "json")
        let decodedObject = try TestingDefaults.jsonDecoder.decode(Token.self, from: data)
        XCTAssertEqual(decodedObject.value, "ZMNBLHLDNJM6JI-LSW8X-Q")
        XCTAssertEqual(decodedObject.expiresAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T12:53:55+02:00"))
        XCTAssertEqual(decodedObject.scope, .all)
        XCTAssertEqual(decodedObject.type, .bearer)
    }

    func testTokenIsValid() throws {
        let tokenIsInvalid = Token(value: "123", expiresAt: Date.init(timeIntervalSinceNow: -5), scope: .all, type: .bearer)
        XCTAssertFalse(tokenIsInvalid.isValid())

        let tokenIsValid = Token(value: "1234", expiresAt: Date.init(timeIntervalSinceNow: 5), scope: .all, type: .bearer)
        XCTAssertTrue(tokenIsValid.isValid())
    }
}
