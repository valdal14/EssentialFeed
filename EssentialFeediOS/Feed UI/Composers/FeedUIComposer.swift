//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 3/1/24.
//

import EssentialFeed

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
		let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
		let feedController = FeedViewController(refreshController: refreshController)
		refreshController.onRefresh = { [weak feedController] feed in
			feedController?.tableModel = feed.map({ feedModel in
				FeedImageCellController(model: feedModel, imageLoader: imageLoader)
			})
		}
		
		return feedController
	}
}
