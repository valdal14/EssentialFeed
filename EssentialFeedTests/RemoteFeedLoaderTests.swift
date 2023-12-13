//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		XCTAssertTrue(client.requestedURLs.isEmpty, "requestedURL was not empty")
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "http://given-url.com")!
		
		let (sut, client) = makeSUT()
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url], "Given url \(url) does not match the requestedURL \(client.messages[0].url)")
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "http://given-url.com")!
		
		let (sut, client) = makeSUT()
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url], "Expected 2 but got \(client.messages.count)")
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: .failure(.connectivity)) {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		}
	}
	
	func test_load_deliversErrorOnNon200HttpResponse() {
		let (sut, client) = makeSUT()
		
		let httpStatusCodes = [199, 201, 300, 400, 500]
		
		httpStatusCodes.enumerated().forEach { (index, code) in
			expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
				let json = makeItemsJSON([])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
			let invalidJSON = "invalid json".data(using: .utf8)!
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: .success([])) {
			let emptyListJSON = """
				{
					"items": []
				}
			""".data(using: .utf8)!
			
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItems(
			id: .init(),
			imageURL: URL(string: "http://img01.png")!
		)
		
		let item2 = makeItems(
			id: .init(),
			description: "Item description",
			location: "Item location",
			imageURL: URL(string: "http://img02.png")!
		)
		
		let items = [item1.model, item2.model]
		
		expect(sut: sut, toCompleteWith: .success(items)) {
			let json = makeItemsJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		}
		
	}
	
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "http://given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		// check for memory leak
		trackForMemoryLeak(sut, file: file, line: line)
		trackForMemoryLeak(client, file: file, line: line)
		return (sut, client)
	}
	
	private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance of should have been decallocated to avoid potential memory leak", file: file, line: line)
		}
	}
	
	private func makeItems(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String : Any]) {
		
		let item = FeedItem(
			id: id,
			description: description,
			location: location,
			imageURL: imageURL
		)
		
		let json: [String : Any] = [
			"id": id.uuidString,
			"description": description,
			"location": location,
			"image": imageURL.absoluteString
		].compactMapValues { $0 }
		
		return (item, json)
	}
	
	func makeItemsJSON(_ items: [[String : Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func expect(sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, file: StaticString = #file, line: UInt = #line, when action: ()-> Void) {
		var capturedResults = [RemoteFeedLoader.Result]()
		sut.load { _ in capturedResults.append(result) }
		
		action()
		
		XCTAssertEqual(capturedResults, [result], file: file, line: line)
	}
	
	// MARK: - HTTPClientSpy
	
	private class HTTPClientSpy: HTTPClient {
		var messages: [(url: URL, completion: ((HTTPClientResult) -> Void))] = []
		
		var requestedURLs: [URL] {
			return messages.compactMap { $0.url }
		}
		
		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			messages.append((url: url, completion: completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedURLs[index],
										   statusCode: code,
										   httpVersion: nil,
										   headerFields: nil)!
			
			messages[index].completion(.success(data, response))
		}
	}
}
