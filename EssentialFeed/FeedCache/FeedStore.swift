//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import Foundation

public protocol FeedStore {
	typealias DeletionCompletion = ((Error?) -> Void)
	typealias InsertionCompletion = ((Error?) -> Void)
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
	func retrieve()
}
