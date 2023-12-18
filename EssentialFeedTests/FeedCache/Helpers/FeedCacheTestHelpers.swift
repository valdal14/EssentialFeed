//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 18/12/23.
//

import EssentialFeed
import Foundation


// MARK: - Helpers
func uniqueImage() -> FeedImage {
	return FeedImage(
		id: .init(),
		description: nil,
		location: nil,
		url: anyURL()
	)
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
	let models = [uniqueImage(), uniqueImage()]
	let localItems = models.map { LocalFeedImage(
		id: $0.id,
		description: $0.description,
		location: $0.location,
		url: $0.imageURL)
	}
	
	return (models, localItems)
}

// MARK: - Date Extension

extension Date {
	
	private var feedCacheMaxAgeInDays: Int {
		return 7
	}
	
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}
	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .init(day: days), to: self)!
	}
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}


