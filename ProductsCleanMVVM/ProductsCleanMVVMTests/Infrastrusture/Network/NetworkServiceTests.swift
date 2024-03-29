//
//  NetworkServiceTests.swift
//  ProductsCleanMVVMTests
//
//  Created by Sajib Ghosh on 13/02/24.
//

import XCTest
@testable import ProductsCleanMVVM

final class NetworkServiceTests: XCTestCase {

    private struct EndpointMock: Requestable {
        var path: String
        var isFullPath: Bool = false
        var method: HTTPMethodType
        var headerParameters: [String: String] = [:]
        var queryParametersEncodable: Encodable?
        var queryParameters: [String: Any] = [:]
        var bodyParametersEncodable: Encodable?
        var bodyParameters: [String: Any] = [:]
        var bodyEncoder: BodyEncoder = AsciiBodyEncoder()
        
        init(path: String, method: HTTPMethodType) {
            self.path = path
            self.method = method
        }
    }
    
    class NetworkErrorLoggerMock: NetworkErrorLogger {
        var loggedErrors: [Error] = []
        func log(request: URLRequest) { }
        func log(responseData data: Data?, response: URLResponse?) { }
        func log(error: Error) { loggedErrors.append(error) }
    }
    
    private enum NetworkErrorMock: Error {
        case someError
    }

    func test_whenMockDataPassed_shouldReturnProperResponse() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let expectedResponseData = "Response data".data(using: .utf8)!
        let sut = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: nil,
                data: expectedResponseData,
                error: nil
            )
        )
        //when
        var endpoint = EndpointMock(path: "http://mock.test.com", method: .get)
        endpoint.isFullPath = true
        _ = sut.request(endpoint: endpoint).sink(receiveCompletion: { completion in
            if case .failure(_) = completion {
                XCTFail("Should return proper response")
                return
            }
        }, receiveValue: { responseData in
            XCTAssertEqual(responseData, expectedResponseData)
            completionCallsCount += 1
        })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenErrorWithNSURLErrorCancelledReturned_shouldReturnCancelledError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let cancelledError = NSError(domain: "network", code: NSURLErrorCancelled, userInfo: nil)
        let sut = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: nil,
                                                                                                  data: nil,
                                                                                                  error: cancelledError as Error))
        //when
        var endpoint = EndpointMock(path: "http://mock.test.com", method: .get)
        endpoint.isFullPath = true
        _ = sut.request(endpoint: endpoint).sink(receiveCompletion: { completion in
            if case .failure(_) = completion {
            }else{
                XCTFail("NetworkError.cancelled not found")
                return
            }
            completionCallsCount += 1
        }, receiveValue: { responseData in
            XCTFail("Should not happen")
        })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenStatusCodeEqualOrAbove400_shouldReturnhasStatusCodeError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 500,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let sut = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: response,
                                                                                                  data: nil,
                                                                                                  error: NetworkErrorMock.someError))
        //when
        var endpoint = EndpointMock(path: "http://mock.test.com", method: .get)
        endpoint.isFullPath = true
        _ = sut.request(endpoint: endpoint).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                if case NetworkError.error(let statusCode, _) = error {
                    XCTAssertEqual(statusCode, 500)
                    completionCallsCount += 1
                }
            }
        }, receiveValue: {_ in
            XCTFail("Should not happen")
        })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenErrorWithNSURLErrorNotConnectedToInternetReturned_shouldReturnNotConnectedError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let error = NSError(domain: "network", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let sut = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: nil,
                                                                                                  data: nil,
                                                                                                  error: error as Error))
        
        //when
        var endpoint = EndpointMock(path: "http://mock.test.com", method: .get)
        endpoint.isFullPath = true
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get))
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    guard case NetworkError.notConnected = error else {
                        XCTFail("NetworkError.notConnected not found")
                        return
                    }
                }
                completionCallsCount += 1
            }, receiveValue: { responseData in
                XCTFail("Should not happen")
            })
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenhasStatusCodeUsedWithWrongError_shouldReturnFalse() {
        //when
        let sut = NetworkError.notConnected
        //then
        XCTAssertFalse(sut.hasStatusCode(200))
    }

    func test_whenhasStatusCodeUsed_shouldReturnCorrectStatusCode_() {
        //when
        let sut = NetworkError.error(statusCode: 400, data: nil)
        //then
        XCTAssertTrue(sut.hasStatusCode(400))
        XCTAssertFalse(sut.hasStatusCode(399))
        XCTAssertFalse(sut.hasStatusCode(401))
    }
    
    func test_whenErrorWithNSURLErrorNotConnectedToInternetReturned_shouldLogThisError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let error = NSError(domain: "network", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let networkErrorLogger = NetworkErrorLoggerMock()
        let sut = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: nil,
                                                                                                  data: nil,
                                                                                                  error: error as Error),logger: networkErrorLogger)
        //when
        var endpoint = EndpointMock(path: "http://mock.test.com", method: .get)
        endpoint.isFullPath = true
        _ = sut.request(endpoint: endpoint)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    guard case NetworkError.notConnected = error else {
                        XCTFail("NetworkError.notConnected not found")
                        return
                    }
                }
                completionCallsCount += 1
            }, receiveValue: { responseData in
                XCTFail("Should not happen")
            })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertTrue(networkErrorLogger.loggedErrors.contains {
            guard case NetworkError.notConnected = $0 else { return false }
            return true
        })
    }

}
