//
//  ValidateFeedCacheUserCaseTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 18/12/23.
//

import EssentialFeed
import XCTest

final class ValidateFeedCacheUserCaseTests: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let(_, store) = makeSUT()
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_validateCache_deletesCacheOnRetrievalError() {
		let(sut, store) = makeSUT()
		sut.validateCache()
		store.completeRetrieval(with: anyNSError())
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
	}
	
	func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
		let(sut, store) = makeSUT()
		sut.validateCache()
		store.completeWithEmptyCache()
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_doesNotDeletesCacheOnNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let(sut, store) = makeSUT() { fixedCurrentDate }
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validateCache_deletesOnCacheExpiration() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiringTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let(sut, store) = makeSUT() { fixedCurrentDate }
		sut.validateCache()
		
		store.completeRetrieval(with: feed.local, timestamp: expiringTimestamp)
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
	}
	
	func test_validateCache_deletesOnExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let(sut, store) = makeSUT() { fixedCurrentDate }
		sut.validateCache()
		
		store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
	}
	
	func test_validateCache_doesNotDeleteInvalidCachefterSUTHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		sut?.validateCache()
		
		sut = nil
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	// MARK: - Helpers
	func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeak(store, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, store)
	}
}
