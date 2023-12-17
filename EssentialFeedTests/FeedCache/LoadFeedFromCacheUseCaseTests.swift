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
