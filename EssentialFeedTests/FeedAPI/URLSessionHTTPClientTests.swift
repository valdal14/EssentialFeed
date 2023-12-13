//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import EssentialFeed
import XCTest

class URLSessionHTTPClient {
	private let session: URLSession
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _, _, error in
			if let error {
				completion(.failure(error))
			}
		}.resume()
	}
}

final class URLSessionHTTPClientTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		URLProtocolStub.startInterceptingRequests()
	}
	
	override func tearDown() {
		super.tearDown()
		URLProtocolStub.stopInterceptingRequests()
	}
	
	func test_getFromURL_failsOnRequestError() {
		let url = URL(string: "http://any-url.com")!
		
		let expectedError = NSError(domain: "any error", code: 400)
		
		URLProtocolStub.stub(data: nil, response: nil, error: expectedError)
		
		let exp = expectation(description: "Wait for the completion")
		
		let sut = URLSessionHTTPClient()
		sut.get(from: url) { result in
			switch result {
			case .success:
				XCTFail("Expected failure but got \(result)")
			case .failure(let receivedError as NSError):
				XCTAssertEqual(receivedError.domain, expectedError.domain, "Expected domain error \(expectedError.domain) but got \(receivedError.domain)")
				XCTAssertEqual(receivedError.code, expectedError.code, "Expected error code \(expectedError.code) but got \(receivedError.code)")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	
}

// MARK: - URLProtocolSpy
private class URLProtocolStub: URLProtocol {
	private static var stub: Stub?
	
	private struct Stub {
		let data: Data?
		let response: URLResponse?
		let error: Error?
	}
	
	static func stub(data: Data?, response: URLResponse?, error: Error?) {
		stub = Stub(data: data, response: response, error: error)
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override func startLoading() {
		
		if let data = URLProtocolStub.stub?.data {
			client?.urlProtocol(self, didLoad: data)
		}
		
		if let response = URLProtocolStub.stub?.response {
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		}
		
		if let error = URLProtocolStub.stub?.error {
			client?.urlProtocol(self, didFailWithError: error)
		}
		
		client?.urlProtocolDidFinishLoading(self)
	}
	
	override func stopLoading() {}
}

// Register and unregister the stubs
extension URLProtocolStub {
	static func startInterceptingRequests() {
		URLProtocolStub.registerClass(URLProtocolStub.self)
	}
	
	static func stopInterceptingRequests() {
		URLProtocolStub.unregisterClass(URLProtocolStub.self)
		stub = nil
	}
}


