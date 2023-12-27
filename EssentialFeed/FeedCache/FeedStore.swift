//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import Foundation

public enum CacheFeed {
	case empty
	case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
	typealias DeletionCompletion = ((Error?) -> Void)
	typealias InsertionCompletion = ((Error?) -> Void)
	typealias RetrieveResult = Swift.Result<CacheFeed, Error>
	typealias RetrievalCompletions = (RetrieveResult) -> Void
	
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispach to appropriated threads if needed.
	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispach to appropriated threads if needed.
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispach to appropriated threads if needed.
	func retrieve(completion: @escaping RetrievalCompletions)
}
