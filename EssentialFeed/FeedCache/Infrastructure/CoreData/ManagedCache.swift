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
