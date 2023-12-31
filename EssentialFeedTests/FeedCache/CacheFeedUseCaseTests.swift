//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 16/12/23.
//

import EssentialFeed
import XCTest


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
		let (sut, store) = makeSUT()
		
		sut.save(uniqueImageFeed().models) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionWithError() {
		let (sut, store) = makeSUT()
		
		let deletionError = anyNSError()
		
		sut.save(uniqueImageFeed().models) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
		let timestamp = Date()
		let feed = uniqueImageFeed()
		
		/**
		 Instead of letting the Use Case produce the current date directly
		 we can move this responsability to a collaborator (Protocol or Closure)
		 and inject it as a depencency. This allow us to easily control this
		 during our tests
		 */
		let (sut, store) = makeSUT { return timestamp }
		
		sut.save(feed.models) { _ in }
		store.completeDeletionSuccssfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed.local, timestamp)])
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
		
	/**
	 When we save and the instance is deallocated we do not want the
	 completion block to be invoked.
	 */
	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.SaveResult]()
		
		sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }
		
		sut = nil
		// complete with an error after sut has been deallocated
		store.completeDeletion(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.SaveResult]()
		
		sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }
		
		store.completeDeletionSuccssfully()
		sut = nil
		store.completeInsertion(with: anyNSError())
		
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
	
	private func expect(sut: LocalFeedLoader, completeWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for save completion to be done")
		var receivedError: Error?
		
		sut.save(uniqueImageFeed().models) { result in
			if case let Result.failure(error) = result { receivedError = error }
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, expectedError)
	}
	
	private func uniqueImage() -> FeedImage {
		return FeedImage(
			id: .init(),
			description: nil,
			location: nil,
			url: anyURL()
		)
	}
	
	private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
		let models = [uniqueImage(), uniqueImage()]
		let localItems = models.map { LocalFeedImage(
			id: $0.id,
			description: $0.description,
			location: $0.location,
			url: $0.imageURL)
		}
		
		return (models, localItems)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
