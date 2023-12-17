//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import EssentialFeed
import Foundation


internal class FeedStoreSpy: FeedStore {
	
	enum ReceivedMessage: Equatable {
		case deleteCacheFeed
		case insert([LocalFeedImage], Date)
		case retrieve
	}
	
	private(set) var receivedMessages: [ReceivedMessage] = []
	
	private var deletionCompletions: [DeletionCompletion] = []
	private var insertionCompletions: [InsertionCompletion] = []
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deletionCompletions.append(completion)
		receivedMessages.append(.deleteCacheFeed)
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccssfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		insertionCompletions.append(completion)
		receivedMessages.append(.insert(feed, timestamp))
	}
	
	func completeInsertion(with error: Error, at index: Int = 0) {
		insertionCompletions[index](error)
	}
	
	func completeInsertionSuccessfully(at index: Int = 0) {
		insertionCompletions[index](nil)
	}
	
	func retrieve() {
		receivedMessages.append(.retrieve)
	}
}
