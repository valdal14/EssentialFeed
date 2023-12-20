//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 19/12/23.
//

import EssentialFeed
import XCTest

class CodableFeedStore {
	private let storeURL: URL
	
	init(storeURL: URL) {
		self.storeURL = storeURL
	}
	
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}
	
	private struct CodableFeedImage: Codable, Equatable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		init(_ image: LocalFeedImage) {
			self.id = image.id
			self.description = image.description
			self.location = image.location
			self.url = image.url
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(
				id: id,
				description: description,
				location: location,
				url: url
			)
		}
	}
	
	func retrieve(completion: @escaping FeedStore.RetrievalCompletions) {
		guard let data = try? Data(contentsOf: storeURL) else { return completion(.empty) }
		let decodedData = try! JSONDecoder().decode(Cache.self, from: data)
		let timestamp = decodedData.timestamp
		let feedImages = decodedData.localFeed
		completion(.found(feed: feedImages, timestamp: timestamp))
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		let codableFeedImage = feed.map { CodableFeedImage($0) }
		let encodedData = try! JSONEncoder().encode(Cache(feed: codableFeedImage, timestamp: timestamp))
		try! encodedData.write(to: storeURL)
		completion(nil)
	}
}

final class CodableFeedStoreTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		undoStoreSideEffects()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		expect(sut, toRetrieve: .empty)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		expect(sut, toRetrieveTwice: .empty)
	}
	
	func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let exp = expectation(description: "Wait for insert cache and retrieve completion to be done")
		sut.insert(feed, timestamp: timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		let exp = expectation(description: "Wait for insert cache and retrieve completion to be done")
		
		sut.insert(feed, timestamp: timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
	}
	
	
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
		let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
	
	private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { retrieveResult in
			switch(expectedResult, retrieveResult) {
			case (.empty, .empty):
				break
			case let (.found(feed: expectedFeed, timestamp: expectedTimestamp), .found(feed: retrievedFeed, timestamp: retrievedTimestamp)):
				XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
				XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
			default:
				XCTFail("Expected to retrieve \(expectedResult) but got \(retrieveResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
	}
}
