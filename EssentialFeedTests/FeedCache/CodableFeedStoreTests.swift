//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 19/12/23.
//

import EssentialFeed
import XCTest

final class CodableFeedStoreTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		undoStoreSideEffects()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		expect(sut, toRetrieve: .empty)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		expect(sut, toRetrieveTwice: .empty)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed: feed, timestamp: timestamp), to: sut)
		
		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed: feed, timestamp: timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_deliversFailureOnRetrievalError() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieve: .failure(anyNSError()))
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}
	
	func test_insert_overridesPreviousInseretdCacheValues() {
		let sut = makeSUT()
		
		let firstInsertionError = insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)
		XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		let latestInsertionError = insert((feed: latestFeed, timestamp: latestTimestamp), to: sut)
		
		XCTAssertNil(latestInsertionError, "Expected to onverride cache successfully")
		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed: feed, timestamp: timestamp), to: sut)
		
		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		let deletedErrror = deleteCache(from: sut)
		
		XCTAssertNil(deletedErrror, "Expected empty cache deletion to succeed")
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_emptiesPreviousltInsertedCache() {
		let sut = makeSUT()
		insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)
		
		let deletedErrror = deleteCache(from: sut)
		
		XCTAssertNil(deletedErrror, "Expected non-empty cache deletion to succeed")
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = cachesDirectory()
		let sut = makeSUT(storeURL: noDeletePermissionURL)
		
		let deletedErrror = deleteCache(from: sut)
		
		XCTAssertNotNil(deletedErrror, "Expected cache deletion to fail with an error")
		expect(sut, toRetrieve: .empty)
	}
	
	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()
		var completedOperationInOrder: [XCTestExpectation] = []
		
		let op1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationInOrder.append(op1)
			op1.fulfill()
		}
		
		let op2 = expectation(description: "Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationInOrder.append(op2)
			op2.fulfill()
		}
		
		let op3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationInOrder.append(op3)
			op3.fulfill()
		}
		
		wait(for: [op1, op2, op3], timeout: 5.0)
		XCTAssertEqual(completedOperationInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
	}
	
	// MARK: - Helpers
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
	
	@discardableResult
	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
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
	
	private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		
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
	
	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}
