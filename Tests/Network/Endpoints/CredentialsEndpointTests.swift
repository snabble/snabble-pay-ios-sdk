//
//  CredentialsEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-25.
//

import XCTest
@testable import SnabblePayNetwork

final class CredentialsEndpointTests: XCTestCase {

    func testGetEndpoint() throws {
        let endpoint = Endpoints.Account.Credentials.get()
        XCTAssertEqual(endpoint.path, "/apps/account/credentials")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testGetIdEndpoint() throws {
        let endpoint = Endpoints.Account.Credentials.get(id: "1")
        XCTAssertEqual(endpoint.path, "/apps/account/credentials/1")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testDeleteIdEndpoint() throws {
        let endpoint = Endpoints.Account.Credentials.delete(id: "1")
        XCTAssertEqual(endpoint.path, "/apps/account/credentials/1")
        XCTAssertEqual(endpoint.method, .delete)
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.Account.Credentials.Mandate.get(credentialsId: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.Account.Credentials.Mandate.accept(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.decline(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.get(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.accept(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.decline(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testDecoder() throws {
        let data = try loadResource(filename: "credentials", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode([Account.Credentials].self, from: data)
        XCTAssertEqual(instance.count, 1)
    }
}
