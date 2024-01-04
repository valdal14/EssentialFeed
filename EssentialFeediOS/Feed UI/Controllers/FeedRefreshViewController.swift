//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 2/1/24.
//

import UIKit

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
	var loadFeed: () -> Void
	public lazy var view = loadView()
	
	init(loadFeed: @escaping () -> Void) {
		self.loadFeed = loadFeed
	}
	
	func display(_ viewModel: FeedLoadingViewModel) {
		if viewModel.isLoading {
			view.beginRefreshing()
		} else {
			view.endRefreshing()
		}
	}
	
	private func loadView() -> UIRefreshControl {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
	
	@objc func refresh() {
		loadFeed()
	}
}
