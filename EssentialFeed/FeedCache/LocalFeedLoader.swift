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
	private static let MAX_AGE_CACHE: Int = 7
	private let calendar = Calendar(identifier: .gregorian)
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	/**
	 TO-DO
	 
	 The LocalFeedLoader should encapsulate application-specific logic only
	 and communication with Models to peform business logic.
	 
	 Rules and Policies ( like this validation and the MAX_AGE_CACHE value)
	 are better suited in a Domain Model that is application-agnostic so it
	 can be reused across application
	 */
	private func validate(_ timestamp: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: Self.MAX_AGE_CACHE, to: timestamp) else { return false }
		return currentDate() < maxCacheAge
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
	public typealias LoadResult = LoadFeedResult
	
	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .failure(let error):
				completion(.failure(error))
			case let .found(feed: feed, timestamp: timestamp) where self.validate(timestamp):
				completion(.success(feed.toModels()))
			case .found, .empty:
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
			case let .found(feed: _, timestamp: timestamp) where !self.validate(timestamp):
				self.store.deleteCachedFeed() { _ in }
			case .empty, .found:
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
