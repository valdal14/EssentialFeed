//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 17/12/23.
//

import Foundation

public struct LocalFeedImage: Codable, Equatable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL
	
	public init(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
}
