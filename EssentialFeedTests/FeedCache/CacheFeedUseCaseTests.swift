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
	
	init(store: FeedStore) {
		self.store = store
	}
	
	func save(_ items: [FeedItem]) {
		/**
		 When we invoke the save(_ items:) method the store.deleteCachedFeed needs to tell us
		 whether the deletion was successful or not and we can address this with a closure. We
		 can either force this operation to be a synch operation or let the framework run the work
		 async. Using the closure we will allow the framework to do it async and maybe on a background queue
		 */
		self.store.deleteCachedFeed { [unowned self] error in
			if error == nil {
				self.store.insert(items)
			} else {
				
			}
		}
	}
}

/**
 Helper class rapresenting the framework side and help defines
 the abstract interface the Use Case needs for its collaborator.
 We do not need to leak framework details into the Use case
 */
class FeedStore {
	typealias DeletionCompletion = ((Error?) -> Void)
	var deleteCacheFeedCallCount: Int = 0
	var insertCountCall: Int = 0
	
	private var deletionCompletions: [((Error?) -> Void)] = []
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deleteCacheFeedCallCount += 1
		deletionCompletions.append(completion)
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccssfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
	
	func insert(_ items: [FeedItem]) {
		insertCountCall += 1
	}
}

// MARK: - Test class

final class CacheFeedUseCaseTests: XCTestCase {
	
	/// delete the old cache
	func test_init_doesNotDeleteCacheUponCreation() {
		/**
		 Here we are not adding any framework details like Codable
		 or CoreData managed context parameters. By test-driving the
		 implementation we endup with the interfaces on how we are going
		 to talk with this store. Then it may be implemented by any specific
		 framework.
		 */
		let(_, store) = makeSUT()
		// Assert we did not delete the cache upon creation
		XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
	}

	func test_save_requestsCacheDeletion() {
		let items: [FeedItem] = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		sut.save(items)
		
		XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionWithError() {
		let items: [FeedItem] = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		let deletionError = anyNSError()
		
		sut.save(items)
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.insertCountCall, 0)
	}
	
	func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
		let items: [FeedItem] = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		sut.save(items)
		store.completeDeletionSuccssfully()
		
		XCTAssertEqual(store.insertCountCall, 1)
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		trackForMemoryLeak(store, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, store)
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
