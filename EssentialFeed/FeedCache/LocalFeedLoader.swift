//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import Foundation

public final class LocalFeedLoader {
	public typealias SaveResult = Error?
	public typealias LoadResult = LoadFeedResult
	
	private let store: FeedStore
	private let currentDate: () -> Date
	
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		self.store.deleteCachedFeed { [weak self] error in
			guard let self = self else { return }
			if let cachedDeletionError = error {
				completion(cachedDeletionError)
			} else {
				self.cache(feed, with: completion)
			}
		}
	}
	
	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { result in
			switch result {
			case .empty:
				completion(.success([]))
			case .failure(let error):
				completion(.failure(error))
			case let .found(feed: feed, timestamp: timestamp):
				completion(.success(feed.toModels()))
			}
		}
	}
	
	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
			guard self != nil else { return }
			completion(error)
		}
	}
}

private extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		self.map { feedItem in
			return LocalFeedImage(
				id: feedItem.id,
				description: feedItem.description,
				location: feedItem.location,
				url: feedItem.imageURL
			)
		}
	}
}

private extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		self.map { localFeedItem in
			return FeedImage(
				id: localFeedItem.id,
				description: localFeedItem.description,
				location: localFeedItem.location,
				url: localFeedItem.url
			)
		}
	}
}
