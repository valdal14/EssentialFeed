//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import Foundation

public final class LocalFeedLoader {
	public typealias SaveResult = Error?
	
	private let store: FeedStore
	private let currentDate: () -> Date
	
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
		self.store.deleteCachedFeed { [weak self] error in
			guard let self = self else { return }
			if let cachedDeletionError = error {
				completion(cachedDeletionError)
			} else {
				self.cache(items, with: completion)
			}
		}
	}
	
	private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
		store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
			guard self != nil else { return }
			completion(error)
		}
	}
}

private extension Array where Element == FeedItem {
	func toLocal() -> [LocalFeedItem] {
		self.map { feedItem in
			return LocalFeedItem(
				id: feedItem.id,
				description: feedItem.description,
				location: feedItem.location,
				imageURL: feedItem.imageURL
			)
		}
	}
}
