//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 9/1/24.
//

import Foundation

// MARK: - Structs
public struct FeedErrorViewModel {
	public let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> FeedErrorViewModel {
		return FeedErrorViewModel(message: message)
	}
}

public struct FeedLoadingViewModel {
	public let isLoading: Bool
}

public struct FeedViewModel {
	public let feed: [FeedImage]
}

// MARK: Protocols

public protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

public protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
	private let feedView: FeedView
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	
	public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.feedView = feedView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public static var title: String {
		return NSLocalizedString(
			"FEED_VIEW_TITLE",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Title for the Feed View"
		)
	}
	
	private var feedLoadError: String {
		return NSLocalizedString(
			"FEED_VIEW_CONNECTION_ERROR",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Error message displayed when we could not load the feed image from the server"
		)
	}
	
	public func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeed(with error: Error) {
		errorView.display(.init(message: feedLoadError))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}
