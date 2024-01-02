//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 2/1/24.
//

import EssentialFeed
import UIKit

final public class FeedRefreshViewController: NSObject {
	private var feedLoader: FeedLoader
	var onRefresh: (([FeedImage]) -> Void)?
	
	public init(feedLoader: FeedLoader) {
		self.feedLoader = feedLoader
	}
	
	public lazy var view: UIRefreshControl = {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}()
	
	@objc func refresh() {
		view.beginRefreshing()
		feedLoader.load(completion: { [weak self] result in
			if let feed = try? result.get() {
				self?.onRefresh?(feed)
			}
			self?.view.endRefreshing()
		})
	}
}
