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
		let refreshController = FeedRefreshViewController(loadFeed: presenter.loadFeed)
		let feedController = FeedViewController(refreshController: refreshController)
		presenter.loadingView = WeakRefVirtualProxy(refreshController)
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
	
	func display(_ viewModel: FeedViewModel) {
		controller?.tableModel = viewModel.feed.map({ feedModel in
			FeedImageCellController(viewModel: FeedImageViewModel(model: feedModel, imageLoader: imageLoader, imageTransformer: UIImage.init))
		})
	}
}

// Move Memory Management details to the Composition layer.
/**
 Proxy Pattern
 
 The Proxy Pattern provides a surrogate or placeholder for another object to control access to it. A Proxy implements the same interface as the object it’s surrogate for. It makes consumers believe they’re talking to the real implementation.
 */

private final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel) {
		object?.display(viewModel)
	}
}
