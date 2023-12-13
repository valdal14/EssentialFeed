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
		session.dataTask(with: url) { _, _, _ in}.resume()
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
	
	func test_getFromURL_resumesDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		
		session.stub(url: url, task: task)
		
		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url)
		
		XCTAssertEqual(task.resumeCallCount, 1, "Expected 1 but got \(task.resumeCallCount)")
	}

	// MARK: - URLSessionHTTPClientSpy
	private class URLSessionSpy: URLSessionProtocol {
		var receivedURLs: [URL] = []
		var stubs: [URL : URLSessionDataTaskProtocol] = [:]
		
		func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
			receivedURLs.append(url)
			return stubs[url] ?? FakeURLSessionDataTask()
		}
		
		func stub(url: URL, task: URLSessionDataTaskProtocol) {
			stubs[url] = task
		}
	}
	
	private class FakeURLSessionDataTask: URLSessionDataTaskProtocol {
		func resume() {}
	}
	
	private class URLSessionDataTaskSpy: URLSessionDataTaskProtocol {
		var resumeCallCount: Int = 0
		
		func resume() {
			resumeCallCount += 1
		}
	}
}


