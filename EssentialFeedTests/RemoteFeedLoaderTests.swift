//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import XCTest
@testable import EssentialFeed

// MARK: -  PROD Code
class RemoteFeedLoader {
	private let client: HTTPClient
	private let url: URL
	
	init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	func load() {
		client.get(from: url)
	}
}

protocol HTTPClient {
	func get(from url: URL)
}


// MARK: - Spy

class HTTPClientSpy: HTTPClient {
	var requestedURL: URL?
	
	func get(from url: URL) {
		requestedURL = url
	}
}

// MARK: - Test

final class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		XCTAssertNil(client.requestedURL, "requestedURL was not nil")
	}
	
	func test_load_requestDataFromURL() {
		let (sut, client) = makeSUT()
		sut.load()
		
		XCTAssertNotNil(client.requestedURL, "requestedURL was nil")
	}
	
	// MARK: - Helpers
	func makeSUT() -> (RemoteFeedLoader, HTTPClientSpy) {
		let url = URL(string: "http://any-url.com")!
		
		let client = HTTPClientSpy()
		return (RemoteFeedLoader(client: client, url: url), client)
	}
}
