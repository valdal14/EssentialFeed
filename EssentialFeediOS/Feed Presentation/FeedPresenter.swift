//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 4/1/24.
//

import EssentialFeed

protocol FeedLoadingView {
	func display(isLoading: Bool)
}

protocol FeedView {
	func display(_ feed: [FeedImage])
}

final class FeedPresenter {
	// typealias Observer<T> = (T) -> Void
	private var feedLoader: FeedLoader
	
	var loadingView: FeedLoadingView?
	var feedView: FeedView?
	
	public init(feedLoader: FeedLoader) {
		self.feedLoader = feedLoader
	}
	
	public func loadFeed() {
		loadingView?.display(isLoading: true)
		feedLoader.load(completion: { [weak self] result in
			if let feed = try? result.get() {
				self?.feedView?.display(feed)
			}
			self?.loadingView?.display(isLoading: false)
		})
	}
}
