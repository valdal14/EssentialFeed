//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader {
	
}

class HTTPClient {
	var requestedURL: URL?
}

// MARK: - Test

final class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let client = HTTPClient()
		_ = RemoteFeedLoader()
		
		XCTAssertNil(client.requestedURL, "requestedURL was not nil")
	}
}
