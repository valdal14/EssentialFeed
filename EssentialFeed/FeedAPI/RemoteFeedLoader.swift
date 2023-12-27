//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public typealias Result = FeedLoader.Result
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case .success((let data, let response)):
				completion(Self.map(data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
		do {
			let items = try RemoteFeedItemsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteFeedItem {
	func toModels() -> [FeedImage] {
		self.map {  FeedImage(
			id: $0.id,
			description: $0.description,
			location: $0.location,
			url: $0.image
		)}
	}
}
