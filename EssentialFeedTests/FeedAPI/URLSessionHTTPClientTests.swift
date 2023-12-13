//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import EssentialFeed
import XCTest

protocol HTTPSessionProtocol {
	func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
	func resume()
}

class URLSessionHTTPClient {
	private let session: HTTPSessionProtocol
	
	init(session: HTTPSessionProtocol) {
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

	func test_getFromURL_resumesDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		
		session.stub(url: url, task: task)
		
		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url) { _ in }
		
		XCTAssertEqual(task.resumeCallCount, 1, "Expected 1 but got \(task.resumeCallCount)")
	}
	
	func test_getFromURL_failsOnRequestError() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		
		let expectedError = NSError(domain: "any error", code: 400)
		
		session.stub(url: url, error: expectedError)
		
		let exp = expectation(description: "Wait for the completion")
		
		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url) { result in
			switch result {
			case .success:
				XCTFail("Expected failure but got \(result)")
			case .failure(let receivedError as NSError):
				XCTAssertEqual(receivedError, expectedError, "Expected error \(expectedError) but got \(receivedError)")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - URLSessionHTTPClientSpy
	private class URLSessionSpy: HTTPSessionProtocol {
		var receivedURLs: [URL] = []
		private var stubs: [URL : Stub] = [:]
		
		private struct Stub {
			let task: HTTPSessionDataTask
			let error: Error?
		}
		
		func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
			receivedURLs.append(url)
			guard let stub = stubs[url] else { fatalError("stubs was not provided for the given \(url)") }
			completionHandler(nil, nil, stub.error)
			return stub.task
		}
		
		func stub(url: URL, task: HTTPSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
			stubs[url] = Stub(task: task, error: error)
		}
	}
	
	private class FakeURLSessionDataTask: HTTPSessionDataTask {
		func resume() {}
	}
	
	private class URLSessionDataTaskSpy: HTTPSessionDataTask {
		var resumeCallCount: Int = 0
		
		func resume() {
			resumeCallCount += 1
		}
	}
	
	// MARK: - URLProtocolSpy
	private class URLProtocolSpy: URLProtocol {
		override class func canInit(with request: URLRequest) -> Bool {
			return true
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			
		}
	}
}


