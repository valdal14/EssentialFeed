//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 16/12/23.
//

import EssentialFeed
import XCTest


/**
 Helper class rapresenting the framework side and help defines
 the abstract interface the Use Case needs for its collaborator.
 We do not need to leak framework details into the Use case
 */
class FeedStore {
	var deleteCacheFeedCallCount: Int = 0
	
	func deleteCachedFeed() {
		deleteCacheFeedCallCount += 1
	}
}

class LocalFeedLoader {
	private let store: FeedStore
	
	init(store: FeedStore) {
		self.store = store
	}
	
	func save(_ items: [FeedItem]) {
		self.store.deleteCachedFeed()
	}
}

final class CacheFeedUseCaseTests: XCTestCase {
	
	/// delete the old cache
	func test_init_doesNotDeleteCacheUponCreation() {
		let store = FeedStore()
		/**
		 Here we are not adding any framework details like Codable
		 or CoreData managed context parameters. By test-driving the
		 implementation we endup with the interfaces on how we are going
		 to talk with this store. Then it may be implemented by any specific
		 framework.
		 */
		_ = LocalFeedLoader(store: store)
		// Assert we did not delete the cache upon creation
		XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
	}

	func test_save_requestsCacheDeletion() {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		let items: [FeedItem] = [uniqueItem(), uniqueItem()]
		
		sut.save(items)
		
		XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
	}
	
	// MARK: - Helpers
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
}
