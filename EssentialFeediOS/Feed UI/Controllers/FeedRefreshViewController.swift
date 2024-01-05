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
	@IBOutlet public var view: UIRefreshControl?
	
	var delegate: FeedRefreshViewControllerDelegate?
	
	func display(_ viewModel: FeedLoadingViewModel) {
		if viewModel.isLoading {
			view?.beginRefreshing()
		} else {
			view?.endRefreshing()
		}
	}
	
	@IBAction func refresh() {
		delegate?.didRequestFeedRefresh()
	}
}
