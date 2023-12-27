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
		/**
		 Now that the RetrievalCompletions completion is Swift.Result<CacheFeed?, Error>
		 is a standard Result type, by just having one completion using the Result type
		 catching initialiser that if an error is thorwn it will automatically wraps it
		 into a failure of the result type and therefore we do not need to use the
		 completion block since it will return a wrapped value of the success case if successfull.
		 
		 We can also eliminate the if else statement by mapping the optional return value
		 of the find method
		 */
		perform { context in
			completion(Result {
				try ManagedCache.find(in: context).map { cache in
					let feed = Self.mapToManagedFeed(from: cache)
					return CacheFeed(feed: feed, timestamp: cache.timestamp)
				}
			})
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			completion(Result {
				let managedFeedImages = try Self.mapToManageCache(from: feed, in: context)
				let cache = try ManagedCache.getNewManagedCacheInstance(in: context)
				cache.feed = NSOrderedSet(array: managedFeedImages)
				cache.timestamp = timestamp
				try context.save()
			})
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			completion(Result {
				try ManagedCache.find(in: context).map(context.delete).map(context.save)
			})
		}
	}
	
	// MARK: - Helpers
	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform { action(context) }
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
