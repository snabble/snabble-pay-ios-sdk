//
//  CredentialsEndpointTest.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import XCTest
@testable import SnabblePayNetwork

final class CredentialsEndpointTests: XCTestCase {
    func testEndpoint() throws {
        let endpoint = Endpoints.Register.post(customUrlScheme: "snabble-pay", apiKeyValue: "123456")
        XCTAssertEqual(endpoint.path, "/apps/register")
        let jsonObject = ["appUrlScheme": "snabble-pay"]
        let dataObject = try! JSONSerialization.data(withJSONObject: jsonObject)
        XCTAssertEqual(endpoint.method, .post(dataObject))
        XCTAssertEqual(endpoint.headerFields["snabblePayKey"], "123456")
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironmentStaging() throws {
        let endpoint = Endpoints.Register.post(customUrlScheme: "snabble-pay", apiKeyValue: "123456", onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)
    }

    func testEnvironmentDevelopment() throws {
        let endpoint = Endpoints.Register.post(customUrlScheme: "snabble-pay", apiKeyValue: "123456", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testDecodingApp() throws {
        let registerData = try loadResource(filename: "register", withExtension: "json")
        let app = try JSONDecoder().decode(App.self, from: registerData)
        XCTAssertEqual(app.identifier, "1l2z79uvnKU18hJ621hDti2Q1mckTs8633HFlUz7PCG1OalckFyKf/TzJlGcOUC4WPInc+RrKCAPLc0loJCtRw==")
        XCTAssertEqual(app.secret, "qPgwvqkVCFn+aFxljTClV7+kTe+18rOQ7Qrdp5YSethhi2X9Sp97UiDkAO3qzXgcdDi/+VazutfHxbA4SZKYWA==")
    }
}
