//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 21/12/23.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let COREDATA_MODEL = "FeedStore"
	private let container: NSPersistentContainer
	
	public init(bundle: Bundle = .main) throws {
		self.container = try NSPersistentContainer.load(modelName: Self.COREDATA_MODEL, in: bundle)
	}
	
	public func retrieve(completion: @escaping RetrievalCompletions) {
		completion(.empty)
	}
	
	public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
}

// MARK: - NSPersistentContainer extension

extension NSPersistentContainer {
	
	enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistentStores(Swift.Error)
	}
	
	static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
			throw LoadingError.modelNotFound
		}
		
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		var loadError: Swift.Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
		
		return container
	}
}

// MARK: - NSManagedObjectModel extension
private extension NSManagedObjectModel {
	static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle
			.url(forResource: name, withExtension: "momd")
			.flatMap { NSManagedObjectModel(contentsOf: $0) }
	}
}
