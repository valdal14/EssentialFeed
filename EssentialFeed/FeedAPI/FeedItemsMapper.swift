//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import Foundation

internal final class FeedItemsMapper {
	private static var OK_200: Int = 200
	
	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL
		
		var item: FeedItem {
			return FeedItem(
				id: self.id,
				description: self.description,
				location: self.location,
				imageURL: self.image
			)
		}
	}
	
	internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
		guard response.statusCode == OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		let root = try JSONDecoder().decode(Root.self, from: data)
		
		return root.items.map { $0.item }
	}
}
