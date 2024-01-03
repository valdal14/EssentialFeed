//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 3/1/24.
//

import EssentialFeed

final class FeedViewModel {
	private var feedLoader: FeedLoader
	var onChange: ((FeedViewModel) -> Void)?
	var onFeedLoad: (([FeedImage]) -> Void)?
	
	public init(feedLoader: FeedLoader) {
		self.feedLoader = feedLoader
	}
	
	private(set) var isLoading: Bool = false {
		didSet {
			onChange?(self)
		}
	}
	
	public func loadFeed() {
		isLoading = true
		feedLoader.load(completion: { [weak self] result in
			if let feed = try? result.get() {
				self?.onFeedLoad?(feed)
			}
			self?.isLoading = false
		})
	}
}
