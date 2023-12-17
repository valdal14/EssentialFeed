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
	
	// MARK: - Helpers
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeak(store, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, store)
	}
}

private extension LoadFeedFromCacheUseCaseTests {
	
	class FeedStoreSpy: FeedStore {
		
		enum ReceivedMessage: Equatable {
			case deleteCacheFeed
			case insert([LocalFeedImage], Date)
		}
		
		private(set) var receivedMessages: [ReceivedMessage] = []
		
		private var deletionCompletions: [DeletionCompletion] = []
		private var insertionCompletions: [InsertionCompletion] = []
		
		func deleteCachedFeed(completion: @escaping DeletionCompletion) {
			deletionCompletions.append(completion)
			receivedMessages.append(.deleteCacheFeed)
		}
		
		func completeDeletion(with error: Error, at index: Int = 0) {
			deletionCompletions[index](error)
		}
		
		func completeDeletionSuccssfully(at index: Int = 0) {
			deletionCompletions[index](nil)
		}
		
		func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessages.append(.insert(feed, timestamp))
		}
		
		func completeInsertion(with error: Error, at index: Int = 0) {
			insertionCompletions[index](error)
		}
		
		func completeInsertionSuccessfully(at index: Int = 0) {
			insertionCompletions[index](nil)
		}
	}
}
