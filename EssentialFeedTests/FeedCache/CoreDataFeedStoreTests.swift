//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 21/12/23.
//
import XCTest
@testable import EssentialFeed

final class CoreDataFeedStore: FeedStore {
	
	func retrieve(completion: @escaping RetrievalCompletions) {
		completion(.empty)
	}
	
	func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
}


final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() {
		
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() {
		
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		
	}
	
	func test_storeSideEffects_runSerially() {
		
	}
	
	// MARK: - Helpers
	func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CoreDataFeedStore()
		trackForMemoryLeak(sut)
		return sut
	}
}
