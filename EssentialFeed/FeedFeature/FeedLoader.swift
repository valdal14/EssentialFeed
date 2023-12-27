//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
