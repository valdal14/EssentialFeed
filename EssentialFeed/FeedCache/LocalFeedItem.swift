//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import Foundation

public struct LocalFeedItem: Decodable, Equatable {
	let id: UUID
	let description: String?
	let location: String?
	let imageURL: URL
	
	public init(id: UUID, description: String?, location: String?, imageURL: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.imageURL = imageURL
	}
}
