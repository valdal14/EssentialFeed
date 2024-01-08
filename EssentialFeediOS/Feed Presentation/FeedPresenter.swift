//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 4/1/24.
//

import EssentialFeed

struct FeedErrorViewModel {
	let message: String?
}

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
	private let feedView: FeedView
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	
	static var title: String {
		let localizedTitle =  LocalizedStringResource(
			"FEED_VIEW_TITLE",
			table: "Feed", 
			locale: .current,
			bundle: LocalizedStringResource.BundleDescription.forClass(FeedPresenter.self),
			comment: "Title for the Feed View"
		)
		return String(localized: localizedTitle)
	}
	
	init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.feedView = feedView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingFeed() {
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingFeed(with error: Error) {
		errorView.display(.init(message: Localized.Feed.loadError))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}
