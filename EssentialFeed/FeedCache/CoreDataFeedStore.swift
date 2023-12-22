//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 21/12/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let COREDATA_MODEL = "FeedStore"
	private static let ENTITY_NAME = ManagedCache.entity().name!
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		self.container = try NSPersistentContainer.load(modelName: Self.COREDATA_MODEL, url: storeURL, in: bundle)
		context = container.newBackgroundContext()
	}
	
	public func retrieve(completion: @escaping RetrievalCompletions) {
		do {
			completion(try retriveCacheResult())
		} catch {
			completion(.empty)
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		do {
			try mapToManageCache(from: feed, timestamp: timestamp)
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			let cache = try getNewManagedCacheInstance(in: context)
			context.delete(cache)
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
}

// MARK: - CoreDataFeedStore extension for RetrieveCachedFeedResult
private extension CoreDataFeedStore {
	
	/// Retrieves the cached feed result from the Core Data context.
	///
	/// - Returns: A `RetrieveCachedFeedResult` representing the cached feed, if found, or an empty result.
	/// - Throws: An error if the fetch operation or mapping encounters issues.
	///
	/// This function attempts to find a `ManagedCache` in the associated Core Data context using the `find` method.
	/// If a cache is found, it maps the cached feed using the `mapToCoreDataFeed` method and returns a
	/// `RetrieveCachedFeedResult.found` case with the mapped feed and timestamp. If no cache is found,
	/// it returns a `RetrieveCachedFeedResult.empty` case.
	///
	private func retriveCacheResult() throws -> RetrieveCachedFeedResult {
		if let cache = try find(in: context) {
			let feed = mapToCoreDataFeed(from: cache)
			return .found(feed: feed.localFeed, timestamp: feed.timestamp)
		} else {
			return .empty
		}
	}
}

// MARK: - CoreDataFeedStore extension for data mapping
private extension CoreDataFeedStore {
	
	private struct CoreDataCache {
		let feed: [CoreDataFeed]
		let timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			return feed.map { $0.localFeedImage }
		}
	}
	
	private struct CoreDataFeed: Equatable {
		private let id: UUID
		private let imageDescription: String?
		private let location: String?
		private let url: URL
		
		init(id: UUID, imageDescription: String?, location: String?, url: URL) {
			self.id = id
			self.imageDescription = imageDescription
			self.location = location
			self.url = url
		}
		
		var localFeedImage: LocalFeedImage {
			return LocalFeedImage(
				id: id,
				description: imageDescription,
				location: location,
				url: url
			)
		}
	}
}

// MARK: - CoreDataFeedStore extension for data mapping helpers
private extension CoreDataFeedStore {
	
	/// Maps a `ManagedCache` instance to a `CoreDataCache` instance.
	///
	/// - Parameters:
	///   - managedCache: The `ManagedCache` instance to be mapped.
	/// - Returns: A `CoreDataCache` instance created from the provided `ManagedCache`.
	///
	private func mapToCoreDataFeed(from managedCache: ManagedCache) -> CoreDataCache {
		let coreDataCachedFeed = managedCache.feed.compactMap { storedFeedImage in
			storedFeedImage as? ManagedFeedImage
		}.compactMap { managedFeedImage in
			CoreDataFeed(
				id: managedFeedImage.id,
				imageDescription: managedFeedImage.imageDescription,
				location: managedFeedImage.location,
				url: managedFeedImage.url
			)
		}
		
		return CoreDataCache(feed: coreDataCachedFeed, timestamp: managedCache.timestamp)
	}
	
	/// Maps an array of `LocalFeedImage` objects to a `ManagedCache` instance.
	///
	/// - Parameters:
	///   - feed: An array of `LocalFeedImage` objects to be mapped to managed entities.
	///   - timestamp: The timestamp to associate with the created `ManagedCache`.
	///
	private func mapToManageCache(from feed: [LocalFeedImage], timestamp: Date) throws {
		
		let managedFeedImages: [ManagedFeedImage] = feed.map { feedImage in
			let managedFeedImage = ManagedFeedImage(context: context)
			managedFeedImage.id = feedImage.id
			managedFeedImage.imageDescription = feedImage.description
			managedFeedImage.location = feedImage.location
			managedFeedImage.url = feedImage.url
			return managedFeedImage
		}
		
		let cache = try getNewManagedCacheInstance(in: context)
		cache.feed = NSOrderedSet(array: managedFeedImages)
		cache.timestamp = timestamp
	}
	
	/// Finds and retrieves a `ManagedCache` instance from the specified Core Data context.
	///
	/// - Parameters:
	///   - context: The `NSManagedObjectContext` in which to perform the fetch operation.
	/// - Returns: A `ManagedCache` instance if found; otherwise, `nil`.
	/// - Throws: An error if the fetch operation encounters issues.
	///
	private func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: Self.ENTITY_NAME)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}
	
	/// Creates a new instance of `ManagedCache` in the specified Core Data context, ensuring uniqueness.
	///
	/// - Parameters:
	///   - context: The `NSManagedObjectContext` in which to create the new `ManagedCache` instance.
	/// - Returns: A new `ManagedCache` instance.
	/// - Throws: An error if the fetch or deletion operation encounters issues.
	///
	/// This function attempts to find an existing `ManagedCache` in the provided Core Data context using the
	/// `find` method. If an existing instance is found, it is deleted to ensure uniqueness. Subsequently,
	/// a new `ManagedCache` instance is created and returned.
	///
	/// - Note: The uniqueness check is based on the assumption that `find` performs a fetch operation that
	///   identifies an existing `ManagedCache` instance.
	///
	private func getNewManagedCacheInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
		try find(in: context).map(context.delete)
		return ManagedCache(context: context)
	}
}
