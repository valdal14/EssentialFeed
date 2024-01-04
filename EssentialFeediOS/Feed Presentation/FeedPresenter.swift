//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 4/1/24.
//

import EssentialFeed

struct FeedLoadingViewModel {
	let isLoading: Bool
}

struct FeedViewModel {
	let feed: [FeedImage]
}

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
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
		loadingView?.display(.init(isLoading: true))
		feedLoader.load(completion: { [weak self] result in
			if let feed = try? result.get() {
				self?.feedView?.display(.init(feed: feed))
			}
			self?.loadingView?.display(.init(isLoading: false))
		})
	}
}
