//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 30/12/23.
//

import UIKit

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
	@IBOutlet public var refreshController: FeedRefreshViewController?
	private var isViewAppeared = false
	var tableModel: [FeedImageCellController] = [] {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
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
		cancelCellController(forRowAt: indexPath)
	}
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			cellController(forRowAt: indexPath).preload()
		}
	}
	
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach(cancelCellController)
	}
	
	private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
		return tableModel[indexPath.row]
	}
	
	// MARK: - Helpers
	private func cancelCellController(forRowAt indexPath: IndexPath) {
		cellController(forRowAt: indexPath).cancelLoad()
	}
}
