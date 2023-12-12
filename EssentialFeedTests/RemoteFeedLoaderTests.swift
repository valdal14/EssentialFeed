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
				client.complete(withStatusCode: code, at: index)
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
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "http://given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		return (RemoteFeedLoader(url: url, client: client), client)
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
		
		func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedURLs[index],
										   statusCode: code,
										   httpVersion: nil,
										   headerFields: nil)!
			
			messages[index].completion(.success(data, response))
		}
	}
}
