//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
}

// MARK: - LocalFeedLoader Save Extension
extension LocalFeedLoader {
	public typealias SaveResult = Error?
	
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
	
	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
			guard self != nil else { return }
			completion(error)
		}
	}
}

// MARK: - LocalFeedLoader Load Extension
extension LocalFeedLoader {
	public typealias LoadResult = FeedLoader.Result
	
	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .failure(let error):
				completion(.failure(error))
			case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
				completion(.success(cache.feed.toModels()))
			case .success:
				completion(.success([]))
			}
		}
	}
}

// MARK: - LocalFeedLoader Validate Cache Extension
extension LocalFeedLoader {
	public func validateCache() {
		store.retrieve() { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .failure:
				self.store.deleteCachedFeed() { _ in }
			case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
				self.store.deleteCachedFeed() { _ in }
			case .success:
				break
			}
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
