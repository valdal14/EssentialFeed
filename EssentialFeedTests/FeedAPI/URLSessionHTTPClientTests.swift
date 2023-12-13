//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import EssentialFeed
import XCTest

protocol URLSessionProtocol {
	func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
	func resume()
}

class URLSessionHTTPClient {
	private let session: URLSessionProtocol
	
	init(session: URLSessionProtocol) {
		self.session = session
	}
	
	func get(from url: URL) {
		session.dataTask(with: url) { _, _, _ in}
	}
}

final class URLSessionHTTPClientTests: XCTestCase {

	func test_getFromURL_createsDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		
		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url)
		
		XCTAssertEqual(session.receivedURLs, [url], "Expected 1 but got \(session.receivedURLs.count)")
	}

	// MARK: - URLSessionHTTPClientSpy
	private class URLSessionSpy: URLSessionProtocol {
		var receivedURLs: [URL] = []
		
		func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
			receivedURLs.append(url)
			return FakeURLSessionDataTask()
		}
	}
	
	private class FakeURLSessionDataTask: URLSessionDataTaskProtocol {
		func resume() {}
	}
}


