//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 22/12/23.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
	@NSManaged public var id: UUID
	@NSManaged public var imageDescription: String?
	@NSManaged public var location: String?
	@NSManaged public var url: URL
	@NSManaged public var cache: ManagedCache
}
