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
		performContextAction { this in
			do {
				completion(try this.retriveCacheResult())
			} catch {
				completion(.empty)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		performContextAction { this in
			do {
				try this.mapToManageCache(from: feed, timestamp: timestamp)
				try this.context.save()
				completion(nil)
			} catch {
				this.context.rollback()
				completion(error)
			}
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		performContextAction { this in
			do {
				try ManagedCache.find(in: this.context).map(this.context.delete).map(this.context.save)
				completion(nil)
			} catch {
				this.context.rollback()
				completion(error)
			}
		}
	}
	
	// MARK: - Helpers
	private func performContextAction(_ asyncBlock: @escaping (CoreDataFeedStore) -> Void) {
		weak var weakSelf = self
		context.perform {
			guard let self = weakSelf else { return }
			asyncBlock(self)
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
		if let cache = try ManagedCache.find(in: context) {
			let feed = mapToManagedFeed(from: cache)
			return .found(feed: feed, timestamp: cache.timestamp)
		} else {
			return .empty
		}
	}
}

// MARK: - CoreDataFeedStore extension for data mapping
private extension CoreDataFeedStore {
	
	private struct CoreDataCache {
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
	private func mapToManagedFeed(from managedCache: ManagedCache) -> [LocalFeedImage] {
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
		
		let cache = try ManagedCache.getNewManagedCacheInstance(in: context)
		cache.feed = NSOrderedSet(array: managedFeedImages)
		cache.timestamp = timestamp
	}
}
