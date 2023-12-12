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
		
		XCTAssertEqual(client.requestedURLs, [url], "Given url \(url) does not match the requestedURL \(client.messages[0].url)")
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "http://given-url.com")!
		
		let (sut, client) = makeSUT()
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url], "Expected 2 but got \(client.messages.count)")
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		var capturedErrors = [RemoteFeedLoader.Error]()
		sut.load { capturedErrors.append($0) }
		
		let clientError = NSError(domain: "Test", code: 0)
		
		client.complete(with: clientError)
		
		XCTAssertEqual(capturedErrors, [.connectivity])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "http://given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		return (RemoteFeedLoader(url: url, client: client), client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var messages: [(url: URL, completion: ((Error) -> Void))] = []
		
		var requestedURLs: [URL] {
			return messages.compactMap { $0.url }
		}
		
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			messages.append((url: url, completion: completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(error)
		}
	}
}
