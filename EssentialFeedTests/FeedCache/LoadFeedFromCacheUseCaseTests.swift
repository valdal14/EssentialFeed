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
		
		let exp = expectation(description: "Wait for load completion")
		
		let retrievalError = anyNSError()
		
		sut.load { result in
			switch result {
			case .failure(let error):
				XCTAssertEqual(error as NSError, retrievalError)
			default:
				XCTFail("Expected error but for \(result) instead")
			}
			
			exp.fulfill()
		}
		
		store.completeRetrieval(with: retrievalError)
		
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeak(store, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
