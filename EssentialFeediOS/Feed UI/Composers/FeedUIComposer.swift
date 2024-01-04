//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 3/1/24.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
		let presenter = FeedPresenter(feedLoader: feedLoader)
		let refreshController = FeedRefreshViewController(presenter: presenter)
		let feedController = FeedViewController(refreshController: refreshController)
		presenter.loadingView = refreshController
		presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
		return feedController
	}
}

// MARK: - Adapter
private final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: FeedImageDataLoader
	
	init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
		self.controller = controller
		self.imageLoader = imageLoader
	}
	
	func display(_ feed: [EssentialFeed.FeedImage]) {
		controller?.tableModel = feed.map({ feedModel in
			FeedImageCellController(viewModel: FeedImageViewModel(model: feedModel, imageLoader: imageLoader, imageTransformer: UIImage.init))
		})
	}
}
