//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 5/1/24.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
	
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing == true
	}
	
	var errorMessage: String? {
		return errorView.message
	}
	
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
		/// instanciate the feedImageView(at row: Int)
		/// that creates images from the data source
		return feedImageView(at: index) as? FeedImageCell
	}
	
	@discardableResult
	func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: row)
		
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedItemSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
		
		return view
	}
	
	func simulateFeedLoading() {
		if !isViewLoaded {
			loadViewIfNeeded()
			replaceRefreshControlWithFakeiOS17Support()
		}
		beginAppearanceTransition(true, animated: false)
		endAppearanceTransition()
	}
	
	func replaceRefreshControlWithFakeiOS17Support() {
		let fake = FakeRefreshControl()
		refreshControl?.allTargets.forEach{ target in
			refreshControl?.actions(forTarget: target, forControlEvent:
					.valueChanged)?.forEach { action in
						fake.addTarget(target, action: Selector(action), for: .valueChanged)
					}
		}
		refreshControl = fake
	}
	
	/**
	 Decoupling the tests from implementation details such as
	 the UITableView methods to get the number of row in section
	 that have been rendered. The objective is to test the behaviour
	 not the implementation.
	 */
	func numberOfRenderedFeedImageViews() -> Int {
		return tableView.numberOfRows(inSection: feedItemSection)
	}
	
	func feedImageView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedItemSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var feedItemSection: Int {
		return 0
	}
	
	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedItemSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}
	
	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewNearVisible(at: row)
		
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedItemSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}
}
