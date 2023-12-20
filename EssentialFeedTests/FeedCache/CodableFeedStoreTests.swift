//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 19/12/23.
//

import EssentialFeed
import XCTest

class CodableFeedStore {
	private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
	
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
		
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
	}
	
	override func tearDown() {
		super.tearDown()
		
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
	}
	
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
		
		let exp = expectation(description: "Wait for first and second cache retrieve completion to be done")
		
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
	
	func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
		let sut = CodableFeedStore()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		let exp = expectation(description: "Wait for insert cache and retrieve completion to be done")
		
		sut.insert(feed, timestamp: timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			sut.retrieve { retrievedResult in
				switch retrievedResult {
				case .found(feed: let retrivedFeed, timestamp: let retrievedTimestamp):
					XCTAssertEqual(feed, retrivedFeed)
					XCTAssertEqual(timestamp, retrievedTimestamp)
				default:
					XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp) but got \(retrievedResult) instead")
				}
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}
