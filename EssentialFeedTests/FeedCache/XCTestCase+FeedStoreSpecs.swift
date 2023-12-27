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
	
	// MARK: - Assertions
	func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
	}
	
	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .success(.some(CacheFeed(feed: feed, timestamp: timestamp))), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .success(.some(CacheFeed(feed: feed, timestamp: timestamp))), file: file, line: line)
	}
	
	func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
	}
	
	func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)
		
		expect(sut, toRetrieve: .success(.some(CacheFeed(feed: latestFeed, timestamp: latestTimestamp))), file: file, line: line)
	}
	
	func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed, timestamp), to: sut)
		
		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
	}
	
	func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		insert((feed, timestamp), to: sut)
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
	
	func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)
		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
	
	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		let deletionError = deleteCache(from: sut)
		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		deleteCache(from: sut)
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
	
	func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		var completedOperationsInOrder = [XCTestExpectation]()
		
		let op1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op1)
			op1.fulfill()
		}
		
		let op2 = expectation(description: "Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(op2)
			op2.fulfill()
		}
		
		let op3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}
		
		waitForExpectations(timeout: 5.0)
		
		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
	}
	
	// MARK: -  Helpers
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for insert cache completion to be done")
		var insertionError: Error?
		
		sut.insert(cache.feed, timestamp: cache.timestamp) { result in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			if case let Result.failure(error) = result { insertionError = error }
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		return insertionError
	}
	
	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for delete cache completion to be done")
		var deletionError: Error?
		
		sut.deleteCachedFeed { result in
			if case let Result.failure(error) = result { deletionError = error }
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrieveResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrieveResult, file: StaticString = #file, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { retrieveResult in
			switch(expectedResult, retrieveResult) {
			case (.success(.none), .success(.none)), (.failure, .failure):
				break
			case let (.success(.some(expected)), .success(.some(retrieved))):
				XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
				XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
				break
			default:
				XCTFail("Expected to retrieve \(expectedResult) but got \(retrieveResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}
