//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 20/12/23.
//

import Foundation

public class CodableFeedStore: FeedStore {
	private let storeURL: URL
	
	/// Serial Queue
	/// It is a background queue but the operation are executed serially
	/// We will not block the main thread but internal operations are executed serially
	private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
	
	public init(storeURL: URL) {
		self.storeURL = storeURL
	}
	
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}
	
	private struct CodableFeedImage: Codable, Equatable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		init(_ image: LocalFeedImage) {
			self.id = image.id
			self.description = image.description
			self.location = image.location
			self.url = image.url
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(
				id: id,
				description: description,
				location: location,
				url: url
			)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletions) {
		/// create a reference to the value type to avoid using self
		/// passing it by copy instead of a reference
		let storeURL = self.storeURL
		
		queue.async {
			guard let data = try? Data(contentsOf: storeURL) else { return completion(.empty) }
			do {
				let decodedData = try JSONDecoder().decode(Cache.self, from: data)
				let timestamp = decodedData.timestamp
				let feedImages = decodedData.localFeed
				completion(.found(feed: feedImages, timestamp: timestamp))
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let storeURL = self.storeURL
		
		queue.async(flags: .barrier) {
			do {
				let codableFeedImage = feed.map { CodableFeedImage($0) }
				let encodedData = try JSONEncoder().encode(Cache(feed: codableFeedImage, timestamp: timestamp))
				try encodedData.write(to: storeURL)
				completion(nil)
			} catch {
				completion(error)
			}
		}
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let storeURL = self.storeURL
		
		queue.async(flags: .barrier) {
			guard FileManager.default.fileExists(atPath: storeURL.path) else {
				return completion(nil)
			}
			
			do {
				try FileManager.default.removeItem(at: storeURL)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
}
