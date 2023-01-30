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
        var endpoint1 = Endpoints.Account.Credentials.get(id: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint1.environment, .staging)

        var endpoint2 = Endpoints.Account.Credentials.get(onEnvironment: .development)
        XCTAssertEqual(endpoint2.environment, .development)

        var endpoint3 = Endpoints.Account.Credentials.delete(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint3.environment, .development)

        endpoint1 = Endpoints.Account.Credentials.get(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint1.environment, .development)

        endpoint2 = Endpoints.Account.Credentials.get(onEnvironment: .development)
        XCTAssertEqual(endpoint2.environment, .development)

        endpoint3 = Endpoints.Account.Credentials.delete(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint3.environment, .development)
    }

    func testDecoder() throws {
        let data = try loadResource(filename: "credentials", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode([Account.Credentials].self, from: data)
        XCTAssertEqual(instance.count, 1)
    }
}
