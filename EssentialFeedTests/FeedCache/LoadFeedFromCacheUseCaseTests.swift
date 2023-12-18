//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import EssentialFeed
import XCTest

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

	func test_init() {
		
		func test_init_doesNotMessageStoreUponCreation() {
			let(_, store) = makeSUT()
			XCTAssertEqual(store.receivedMessages, [])
		}
	}
	
	func test_load_requestCacheRetrieval() {
		let(sut, store) = makeSUT()
		
		sut.load() { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_failsOnRetrieveError() {
		let(sut, store) = makeSUT()
		
		let retrievalError = anyNSError()
		
		expect(sut, toCompleteWith: .failure(anyNSError())) {
			store.completeRetrieval(with: retrievalError)
		}
	}
	
	func test_load_deliversNoImagesOnEmptyCache() {
		let(sut, store) = makeSUT()

		expect(sut, toCompleteWith: .success([])) {
			store.completeWithEmptyCache()
		}
	}
	
	func test_load_deliversCachedImagesOnNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		
		let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let(sut, store) = makeSUT() { fixedCurrentDate }
		
		expect(sut, toCompleteWith: .success(feed.models)) {
			store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
		}
	}
	
	func test_load_deliversNoImagesOnCacheExpiration() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		
		let expiringTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let(sut, store) = makeSUT() { fixedCurrentDate }
		
		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrieval(with: feed.local, timestamp: expiringTimestamp)
		}
	}
	
	func test_load_deliversNoImagesOnExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		
		let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let(sut, store) = makeSUT() { fixedCurrentDate }
		
		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
		}
	}
	
	func test_load_hasNoSideEffectsCacheOnRetrievalError() {
		let(sut, store) = makeSUT()
		sut.load() { _ in }
		store.completeRetrieval(with: anyNSError())
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_hasNoSideEffectsOnEmptyCache() {
		let(sut, store) = makeSUT()
		sut.load() { _ in }
		store.completeWithEmptyCache()
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_hasNotSideEffectsOnNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let(sut, store) = makeSUT() { fixedCurrentDate }
		sut.load() { _ in }
		store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_hasNoSideEffectsOnCacheExpiration() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiringTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let(sut, store) = makeSUT() { fixedCurrentDate }
		sut.load() { _ in }
		
		store.completeRetrieval(with: feed.local, timestamp: expiringTimestamp)
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_hasNoSideEffectsOnExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let(sut, store) = makeSUT() { fixedCurrentDate }
		sut.load() { _ in }
		
		store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.LoadResult]()
		
		sut?.load(completion: { receivedResults.append($0) })
		
		sut = nil
		store.completeWithEmptyCache()
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	// MARK: - Helpers
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeak(store, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWith exptectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, exptectedResult) {
			case let (.success(receivedImages), .success(expectedImages)):
				XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail("Expected result \(exptectedResult) but for \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
}
