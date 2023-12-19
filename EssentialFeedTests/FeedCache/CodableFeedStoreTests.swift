//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 19/12/23.
//

import EssentialFeed
import XCTest


class CodableFeedStore {
	
	func retrieve(completion: @escaping FeedStore.RetrievalCompletions) {
		completion(.empty)
	}
}

final class CodableFeedStoreTests: XCTestCase {
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = CodableFeedStore()
		
		let exp = expectation(description: "Wait for cache retrieve completion to be done")
		
		sut.retrieve { result in
			switch result {
			case .empty:
				break
			default:
				XCTFail("Expected empty result but got \(result) instead")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = CodableFeedStore()
		
		let exp = expectation(description: "Wait for first cache retrieve completion to be done")
		
		sut.retrieve { firstResult in
			sut.retrieve { secondResult in
				switch (firstResult, secondResult) {
				case (.empty, .empty):
					break
				default:
					XCTFail("Expected retrieving twice from empty cache to deliver same empty rsult but go \(firstResult) and \(secondResult) instead")
				}
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}

}
