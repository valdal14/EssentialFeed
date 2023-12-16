//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 16/12/23.
//

import EssentialFeed
import XCTest


class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	
	init(store: FeedStore, currentDate: @escaping () -> Date ) {
		self.store = store
		self.currentDate = currentDate
	}
	
	func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
		self.store.deleteCachedFeed { [unowned self] error in
			if error == nil {
				/// here we can pass just the completion since they have the same signature
				self.store.insert(items, timestamp: self.currentDate(), completion: completion)
			} else {
				completion(error)
			}
		}
	}
}

protocol FeedStore {
	typealias DeletionCompletion = ((Error?) -> Void)
	typealias InsertionCompletion = ((Error?) -> Void)
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

// MARK: - Test class

final class CacheFeedUseCaseTests: XCTestCase {
	
	/// delete the old cache
	func test_init_doesNotMessageStoreUponCreation() {
		/**
		 Here we are not adding any framework details like Codable
		 or CoreData managed context parameters. By test-driving the
		 implementation we endup with the interfaces on how we are going
		 to talk with this store. Then it may be implemented by any specific
		 framework.
		 */
		let(_, store) = makeSUT()
		// Assert we did not delete the cache upon creation
		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_save_requestsCacheDeletion() {
		let items: [FeedItem] = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		sut.save(items) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionWithError() {
		let items: [FeedItem] = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		let deletionError = anyNSError()
		
		sut.save(items) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
		let timestamp = Date()
		let items: [FeedItem] = [uniqueItem(), uniqueItem()]
		/**
		 Instead of letting the Use Case produce the current date directly
		 we can move this responsability to a collaborator (Protocol or Closure)
		 and inject it as a depencency. This allow us to easily control this
		 during our tests
		 */
		let (sut, store) = makeSUT { return timestamp }
		
		sut.save(items) { _ in }
		store.completeDeletionSuccssfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timestamp)])
	}
	
	func test_save_failsOnDeletionWithError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		expect(sut: sut, completeWithError: deletionError) {
			store.completeDeletion(with: deletionError)
		}
	}
	
	func test_save_failsOnInsertingError() {
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()
		
		expect(sut: sut, completeWithError: insertionError) {
			store.completeDeletionSuccssfully()
			store.completeInsertion(with: insertionError)
		}
	}
	
	func test_save_succedsOnSuccessfulCacheInserting() {
		let (sut, store) = makeSUT()
		
		expect(sut: sut, completeWithError: nil) {
			store.completeDeletionSuccssfully()
			store.completeInsertionSuccessfully()
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
	
	private func expect(sut: LocalFeedLoader, completeWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for save completion to be done")
		var receivedError: Error?
		
		sut.save([uniqueItem()]) { error in
			receivedError = error
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, expectedError)
	}
	
	private func uniqueItem() -> FeedItem {
		return FeedItem(
			id: .init(),
			description: nil,
			location: nil,
			imageURL: anyURL()
		)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}

// MARK: - FeedStoreSpy

private extension CacheFeedUseCaseTests {
	
	class FeedStoreSpy: FeedStore {
		
		enum ReceivedMessage: Equatable {
			case deleteCacheFeed
			case insert([FeedItem], Date)
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
		
		func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessages.append(.insert(items, timestamp))
		}
		
		func completeInsertion(with error: Error, at index: Int = 0) {
			insertionCompletions[index](error)
		}
		
		func completeInsertionSuccessfully(at index: Int = 0) {
			insertionCompletions[index](nil)
		}
	}

}
