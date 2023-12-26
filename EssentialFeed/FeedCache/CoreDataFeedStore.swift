//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 21/12/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let COREDATA_MODEL = "FeedStore"
	private static let model = NSManagedObjectModel.with(name: COREDATA_MODEL, in: Bundle(for: CoreDataFeedStore.self))
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	private enum StoreError: Error {
		case modelNotFound
		case failedLoadingPersistentContainer(Error)
	}
	
	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw StoreError.modelNotFound
		}
		
		do {
			container = try NSPersistentContainer.load(
				name: Self.COREDATA_MODEL,
				model: model,
				url: storeURL
			)
			context = container.newBackgroundContext()
		} catch {
			throw StoreError.failedLoadingPersistentContainer(error)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletions) {
		perform { context in
			do {
				completion(try Self.retriveCacheResult(in: context))
			} catch {
				completion(.empty)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			do {
				let managedFeedImages = try Self.mapToManageCache(from: feed, in: context)
				let cache = try ManagedCache.getNewManagedCacheInstance(in: context)
				cache.feed = NSOrderedSet(array: managedFeedImages)
				cache.timestamp = timestamp
				try context.save()
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				try ManagedCache.find(in: context).map(context.delete).map(context.save)
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}
	
	// MARK: - Helpers
	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform { action(context) }
	}
}

// MARK: - CoreDataFeedStore extension for RetrieveCachedFeedResult
private extension CoreDataFeedStore {
	
	/// Retrieves the cached feed result from the specified Core Data context.
	///
	/// - Parameters:
	///   - context: The `NSManagedObjectContext` in which the cache is retrieved.
	/// - Returns: A `RetrieveCachedFeedResult` indicating the outcome of the retrieval.
	///   - If a cached feed is found, returns `.found(feed:timestamp:)` with the mapped feed and timestamp.
	///   - If no cached feed is found, returns `.empty`.
	/// - Throws: An error of type `Error` if there is an issue during the retrieval process.
	///
	static func retriveCacheResult(in context: NSManagedObjectContext) throws -> RetrieveCachedFeedResult {
		if let cache = try ManagedCache.find(in: context) {
			let feed = Self.mapToManagedFeed(from: cache)
			return .found(feed: feed, timestamp: cache.timestamp)
		} else {
			return .empty
		}
	}
}

// MARK: - CoreDataFeedStore extension for data mapping
private extension CoreDataFeedStore {
	
	struct CoreDataCache {
		let feed: [ManagedFeedImage]
		let timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			return feed.map { feed in
				return LocalFeedImage(
					id: feed.id,
					description: feed.imageDescription,
					location: feed.location,
					url: feed.url
				)
			}
		}
	}
}

// MARK: - CoreDataFeedStore extension for data mapping helpers
private extension CoreDataFeedStore {
	
	/// Maps a `ManagedCache` instance to an array of `LocalFeedImage` instances.
	///
	/// - Parameters:
	///   - managedCache: The `ManagedCache` instance to be mapped.
	/// - Returns: An array of `ManagedFeedImage` instances
	///
	static func mapToManagedFeed(from managedCache: ManagedCache) -> [LocalFeedImage] {
		let localFeedImages = managedCache.feed.compactMap { storedFeedImage in
			storedFeedImage as? ManagedFeedImage
		}.compactMap { return LocalFeedImage(
			id: $0.id,
			description: $0.imageDescription,
			location: $0.location,
			url: $0.url)
		}
		
		return localFeedImages
	}
	
	/// Maps an array of `LocalFeedImage` objects to a `ManagedCache` instance.
	///
	/// - Parameters:
	///   - feed: An array of `LocalFeedImage` objects to be mapped to managed entities.
	///	  - context: `NSManagedObjectContext` instance
	///
	static func mapToManageCache(from feed: [LocalFeedImage], in context: NSManagedObjectContext) throws -> [ManagedFeedImage] {
		
		return feed.map { feedImage in
			let managedFeedImage = ManagedFeedImage(context: context)
			managedFeedImage.id = feedImage.id
			managedFeedImage.imageDescription = feedImage.description
			managedFeedImage.location = feedImage.location
			managedFeedImage.url = feedImage.url
			return managedFeedImage
		}
	}
}
