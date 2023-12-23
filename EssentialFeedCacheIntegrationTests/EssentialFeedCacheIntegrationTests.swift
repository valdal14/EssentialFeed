//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Valerio D'ALESSIO on 23/12/23.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

	override func setUp() {
		super.setUp()
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		undoStoreSideEffects()
	}
	
	func test_load_deliversNoItemsOnEmptyCache() throws {
		let sut = try makeSUT()
		expect(sut, toLoad: [])
	}
	
	func test_load_deliversItemsSavedOnSepearatedInstance() throws {
		let sutToPerformSave = try makeSUT()
		let sutToPerformLoad = try makeSUT()
		
		let feed = uniqueImageFeed().models
		
		expect(sutToPerformSave, toSave: feed)
		expect(sutToPerformLoad, toLoad: feed)
		
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> LocalFeedLoader {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = testSpecificStoreURL()
		let store = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
		let sut = LocalFeedLoader(store: store, currentDate: Date.init)
		trackForMemoryLeak(store, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
	
	private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case .success(let imageFeed):
				XCTAssertEqual(imageFeed, expectedFeed, "Expected empty feed", file: file, line: line)
			case .failure(let error):
				XCTFail("Expected successful feed result but got \(error) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func expect(_ sut: LocalFeedLoader, toSave items: [FeedImage], file: StaticString = #file, line: UInt = #line) {
		let saveExp = expectation(description: "Wait for save completion")
		sut.save(items) { saveError in
			XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
			saveExp.fulfill()
		}
		wait(for: [saveExp], timeout: 1.0)
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
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}
