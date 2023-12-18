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

	func test_validateCache_doesNotDeletesCacheOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let(sut, store) = makeSUT() { fixedCurrentDate }
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	// MARK: - Helpers
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeak(store, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, store)
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
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
}

private extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .init(day: days), to: self)!
	}
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
