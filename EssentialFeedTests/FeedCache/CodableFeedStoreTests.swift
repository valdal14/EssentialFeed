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

}
