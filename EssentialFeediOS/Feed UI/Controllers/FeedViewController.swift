//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 30/12/23.
//

import EssentialFeed
import UIKit

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
	public var refreshController: FeedRefreshViewController?
	private var imageLoader: FeedImageDataLoader?
	private var isViewAppeared = false
	private var tableModel: [FeedImage] = [] {
		didSet {
			tableView.reloadData()
		}
	}
	private var cellControllers: [IndexPath : FeedImageCellController] = [:]
	
	public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
		self.init()
		self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
		self.imageLoader = imageLoader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = refreshController?.view
		refreshController?.onRefresh = { [weak self] feed in
			self?.tableModel = feed
		}
		tableView.prefetchDataSource = self
		refreshController?.refresh()
	}
	
	public override func viewIsAppearing(_ animated: Bool) {
		super.viewIsAppearing(animated)
		if !isViewAppeared {
			refreshControl?.beginRefreshing()
			isViewAppeared = true
		}
	}
}

//MARK: - FeedViewController TableView DataSource Delegation
public extension FeedViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellController(forRowAt: indexPath).view()
	}
	
	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		removeCellController(forRowAt: indexPath)
	}
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			cellController(forRowAt: indexPath).preload()
		}
	}
	
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach(removeCellController)
	}
	
	private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
		let cellModel = tableModel[indexPath.row]
		let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
		cellControllers[indexPath] = cellController
		return cellController
	}
	
	// MARK: - Helpers
	private func removeCellController(forRowAt indexPath: IndexPath) {
		cellControllers[indexPath] = nil
	}
}
