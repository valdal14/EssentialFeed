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
	private var tasks: [IndexPath : FeedImageDataLoaderTask] = [:]
	
	
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
		let cellModel = tableModel[indexPath.row]
		let cell = FeedImageCell()
		cell.locationContainer.isHidden = (cellModel.location != nil) ? false : true
		cell.locationLabel.text = cellModel.location
		cell.descriptionLabel.text = cellModel.description
		cell.feedImageView.image = nil
		cell.feedImageRetryButton.isHidden = true
		cell.feedImageContainer.startShimmering()
		tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
			let data = try? result.get()
			let image = data.map(UIImage.init) ?? nil
			cell?.feedImageView.image = image
			cell?.feedImageRetryButton.isHidden = (image != nil)
			cell?.feedImageContainer.stopShimmering()
		}
		
		let loadImage = { [weak self, weak cell] in
			guard let self = self else { return }
			
			self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
				let data = try? result.get()
				let image = data.map(UIImage.init) ?? nil
				cell?.feedImageView.image = image
				cell?.feedImageRetryButton.isHidden = (image != nil)
				cell?.feedImageContainer.stopShimmering()
			}
		}
		
		cell.onRetry = loadImage
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cancelTask(forRowAt: indexPath)
	}
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let cellModel = tableModel[indexPath.row]
			tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL, completion: { _ in })
		}
	}
	
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach(cancelTask)
	}
	
	// MARK: - Helpers
	private func cancelTask(forRowAt indexPath: IndexPath) {
		tasks[indexPath]?.cancel()
		tasks[indexPath] = nil
	}
}
