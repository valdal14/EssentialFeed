//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 22/12/23.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
	private static let ENTITY_NAME = entity().name!
	
	@NSManaged public var timestamp: Date
	@NSManaged public var feed: NSOrderedSet
}


internal extension ManagedCache {
	/// Finds and retrieves a `ManagedCache` instance from the specified Core Data context.
	///
	/// - Parameters:
	///   - context: The `NSManagedObjectContext` in which to perform the fetch operation.
	/// - Returns: A `ManagedCache` instance if found; otherwise, `nil`.
	/// - Throws: An error if the fetch operation encounters issues.
	///
	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
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
	static func getNewManagedCacheInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
		try find(in: context).map(context.delete)
		return ManagedCache(context: context)
	}
}
