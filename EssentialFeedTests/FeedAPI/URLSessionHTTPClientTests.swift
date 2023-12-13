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
	
	struct UnexpectedValuesRapresentation: Error {}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _, _, error in
			if let error {
				completion(.failure(error))
			} else {
				completion(.failure(UnexpectedValuesRapresentation()))
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
	
	func test_getFromURL_performsGETRequestWithURL() {
		let url = anyURL()
		let exp = expectation(description: "Wait for the completion")
		
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}
		
		makeSUT().get(from: anyURL()) { _ in }
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_getFromURL_failsOnRequestError() {
		let requestError = anyNSError()
		let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
		XCTAssertNotNil(receivedError)
	}
	
	func test_getFromURL_failsOnAllInvalidRepresentationCases() {
		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
	}
	
	// MARK: - Halpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
	
	private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
		URLProtocolStub.stub(data: data, response: response, error: error)
		let sut = makeSUT(file: file, line: line)
		let exp = expectation(description: "Wait for the completion")
		
		var receivedError: Error?
		
		sut.get(from: anyURL()) { result in
			switch result {
			case .failure(let error):
				receivedError = error
			default:
				XCTFail("Expected invalid but for \(result)", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return receivedError
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func anyData() -> Data {
		return "any data".data(using: .utf8)!
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private func anyHTTPURLResponse() -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func nonHTTPURLResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
}

// MARK: - URLProtocolSpy
private class URLProtocolStub: URLProtocol {
	private static var stub: Stub?
	private static var requestObserver: ((URLRequest) -> Void)?
	
	private struct Stub {
		let data: Data?
		let response: URLResponse?
		let error: Error?
	}
	
	static func stub(data: Data?, response: URLResponse?, error: Error?) {
		stub = Stub(data: data, response: response, error: error)
	}
	
	static func observeRequests(observer: @escaping (URLRequest) -> Void) {
		requestObserver = observer
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		requestObserver?(request)
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
		requestObserver = nil
	}
}


