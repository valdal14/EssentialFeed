//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import Foundation

enum LoadFeedResult {
	case success([FeedItem])
	case error(Error)
}

protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
