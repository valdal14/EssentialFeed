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
	private let loadingView: FeedLoadingView
	private let feedView: FeedView
	
	init(loadingView: FeedLoadingView, feedView: FeedView) {
		self.loadingView = loadingView
		self.feedView = feedView
	}
	
	func didStartLoadingFeed() {
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingFeed(with error: Error) {
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}
