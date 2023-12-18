//
//  RemoteFeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import Foundation

internal final class RemoteFeedItemsMapper {
	private static var OK_200: Int = 200
	
	private struct Root: Decodable {
		let items: [RemoteFeedItem]
	}
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
		guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		return root.items
	}
}
