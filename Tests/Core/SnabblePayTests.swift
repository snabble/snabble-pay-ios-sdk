//
//  SnabblePayTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-01.
//

import XCTest
@testable import SnabblePay
import TestHelper

final class SnabblePayTests: XCTestCase {

    let instance: SnabblePay = SnabblePay(apiKey: "1234", urlSession: .mockSession)
    var account: Account! = nil

    private var injectedResponse: ((URLRequest) -> (HTTPURLResponse, Data))! = { request in
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (response, Data())
    }

    override func setUpWithError() throws {
        let jsonData = try! loadResource(inBundle: .module, filename: "account-id", withExtension: "json")
        account = try! TestingDefaults.jsonDecoder.decode(Account.self, from: jsonData)
        
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { [self] request in
            if request.url?.path == "/apps/register" {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, try! loadResource(inBundle: .module, filename: "register", withExtension: "json"))
            }

            if request.url?.path == "/apps/token" {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, try! loadResource(inBundle: .module, filename: "token", withExtension: "json"))
            }

            return self.injectedResponse(request)
        }
    }

    override func tearDownWithError() throws {
        injectedResponse = nil
    }


    func testAccountCheckSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(inBundle: .module, filename: "account-check", withExtension: "json"))
        }
        let expectation = expectation(description: "testAccountCheckSuccess")
        instance.accountCheck(withAppUri: "snabble-pay://account/check") { result in
            switch result {
            case let .success(accountCheck):
                XCTAssertNotNil(accountCheck)
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAccountCheckFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testAccountCheckFailure")
        instance.accountCheck(withAppUri: "snabble-pay://account/check") { result in
            switch result {
            case let .success(accountCheck):
                XCTAssertNil(accountCheck)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAccountsSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(inBundle: .module, filename: "accounts-many", withExtension: "json"))
        }
        let expectation = expectation(description: "testAccountsSuccess")
        instance.accounts() { result in
            switch result {
            case let .success(accounts):
                XCTAssertNotNil(accounts)
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAccountsFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testAccountsFailure")
        instance.accounts() { result in
            switch result {
            case let .success(accounts):
                XCTAssertNil(accounts)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAccountSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(inBundle: .module, filename: "account-id", withExtension: "json"))
        }
        let expectation = expectation(description: "testAccountSuccess")
        instance.account(withId: "1") { result in
            switch result {
            case let .success(account):
                XCTAssertNotNil(account)
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAccountFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testAccountFailure")
        instance.account(withId: "1") { result in
            switch result {
            case let .success(account):
                XCTAssertNil(account)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testDeleteAccountSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testDeleteAccountSuccess")
        instance.delete(account: account) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testDeleteAccountFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testDeleteAccountFailure")
        instance.delete(account: account) { result in
            switch result {
            case let .success(instance):
                XCTAssertNil(instance)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testMandateSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(inBundle: .module, filename: "mandate", withExtension: "json"))
        }
        let expectation = expectation(description: "testMandateSuccess")
        instance.mandate(forAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNotNil(mandate)
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testMandateFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testMandateFailure")
        instance.mandate(forAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNil(mandate)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAcceptMandateSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(inBundle: .module, filename: "mandate", withExtension: "json"))
        }
        let expectation = expectation(description: "testAcceptMandateSuccess")
        instance.acceptMandate(forAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNotNil(mandate)
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAcceptAccountFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testAcceptAccountFailure")
        instance.acceptMandate(forAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNil(mandate)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testDeclineMandateSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(inBundle: .module, filename: "mandate", withExtension: "json"))
        }
        let expectation = expectation(description: "testDeclineMandateSuccess")
        instance.declineMandate(forAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNotNil(mandate)
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testDeclineMandateFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testDeclineMandateFailure")
        instance.declineMandate(forAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNil(mandate)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testSessionSuccess() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(inBundle: .module, filename: "session-post", withExtension: "json"))
        }
        let expectation = expectation(description: "testSessionSuccess")
        instance.startSession(withAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNotNil(mandate)
                expectation.fulfill()
            case .failure:
                XCTFail("shouldn't happen")
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testSessionFailure() throws {
        injectedResponse = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        let expectation = expectation(description: "testSessionFailure")
        instance.startSession(withAccount: account) { result in
            switch result {
            case let .success(mandate):
                XCTAssertNil(mandate)
            case let .failure(error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }
}
