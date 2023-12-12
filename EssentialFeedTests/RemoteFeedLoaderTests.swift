//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		XCTAssertTrue(client.requestedURLs.isEmpty, "requestedURL was not empty")
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "http://given-url.com")!
		
		let (sut, client) = makeSUT()
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url], "Given url \(url) does not match the requestedURL \(client.requestedURLs)")
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "http://given-url.com")!
		
		let (sut, client) = makeSUT()
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url], "Expected 2 but got \(client.requestedURLs.count)")
	}
	
	func test_load_deliversErrorOnClientError() {
		let url = URL(string: "http://given-url.com")!
		
		let (sut, client) = makeSUT()
		client.error = NSError(domain: "any error", code: 400)
		
		var capturedError: RemoteFeedLoader.Error?
		
		sut.load { capturedError = $0 }
		
		XCTAssertEqual(capturedError, .connectivity)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "http://given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		return (RemoteFeedLoader(url: url, client: client), client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var requestedURLs: [URL] = []
		var error: Error?
		
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			if let error {
				completion(error)
			}
			requestedURLs.append(url)
		}
	}
}
