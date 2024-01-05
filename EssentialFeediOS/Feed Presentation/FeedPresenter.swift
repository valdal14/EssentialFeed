//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 4/1/24.
//

import EssentialFeed

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
	private let feedView: FeedView
	private let loadingView: FeedLoadingView
	
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
	
	init(feedView: FeedView, loadingView: FeedLoadingView) {
		self.feedView = feedView
		self.loadingView = loadingView
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
