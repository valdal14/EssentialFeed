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
		XCTAssertNil(client.requestedURL, "requestedURL was not nil")
	}
	
	func test_load_requestsDataFromURL() {
		let givenURL = URL(string: "http://given-url.com")!
		
		let (sut, client) = makeSUT()
		sut.load()
		
		XCTAssertEqual(client.requestedURL, givenURL, "Given url \(givenURL) does not match the requestedURL \(String(describing: client.requestedURL))")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "http://given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		return (RemoteFeedLoader(url: url, client: client), client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var requestedURL: URL?
		
		func get(from url: URL) {
			requestedURL = url
		}
	}
}
