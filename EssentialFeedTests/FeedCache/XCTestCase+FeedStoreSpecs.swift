//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 21/12/23.
//

import EssentialFeed
import XCTest


/**
 Constraining the protocol to XCTestCase in order to access
 to the assertions methods and document this protocol extension
 is for tests only
 */
extension FeedStoreSpecs where Self: XCTestCase {
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for insert cache completion to be done")
		var insertionError: Error?
		
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		return insertionError
	}
	
	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for delete cache completion to be done")
		var deletionError: Error?
		
		sut.deleteCachedFeed { receivedError in
			deletionError = receivedError
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { retrieveResult in
			switch(expectedResult, retrieveResult) {
			case (.empty, .empty), (.failure, .failure):
				break
			case let (.found(feed: expectedFeed, timestamp: expectedTimestamp), .found(feed: retrievedFeed, timestamp: retrievedTimestamp)):
				XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
				XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
			default:
				XCTFail("Expected to retrieve \(expectedResult) but got \(retrieveResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}
