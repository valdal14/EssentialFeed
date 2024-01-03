//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 3/1/24.
//

import EssentialFeed

final class FeedViewModel {
	typealias Observer<T> = (T) -> Void
	private var feedLoader: FeedLoader
	
	var onLoadingStateChange: Observer<Bool>?
	var onFeedLoad: Observer<[FeedImage]>?
	
	public init(feedLoader: FeedLoader) {
		self.feedLoader = feedLoader
	}
	
	public func loadFeed() {
		onLoadingStateChange?(true)
		feedLoader.load(completion: { [weak self] result in
			if let feed = try? result.get() {
				self?.onFeedLoad?(feed)
			}
			self?.onLoadingStateChange?(false)
		})
	}
}
