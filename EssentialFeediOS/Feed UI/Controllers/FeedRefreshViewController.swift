//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 2/1/24.
//

import UIKit

final public class FeedRefreshViewController: NSObject {
	private let viewModel: FeedViewModel
	
	init(viewModel: FeedViewModel) {
		self.viewModel = viewModel
	}
	
	public lazy var view = binded(UIRefreshControl())
	
	private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
		viewModel.onChange = { [weak self] viewModel in
			if viewModel.isLoading {
				self?.view.beginRefreshing()
			} else {
				self?.view.endRefreshing()
			}
		}
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
	
	@objc func refresh() {
		viewModel.loadFeed()
	}
}
