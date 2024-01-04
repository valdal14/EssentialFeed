//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 2/1/24.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
	func didRequestFeedRefresh()
}

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
	public lazy var view = loadView()
	
	private let delegate: FeedRefreshViewControllerDelegate
	
	init(delegate: FeedRefreshViewControllerDelegate) {
		self.delegate = delegate
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
		delegate.didRequestFeedRefresh()
	}
}
