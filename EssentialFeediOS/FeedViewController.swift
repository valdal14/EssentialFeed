//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 30/12/23.
//

import EssentialFeed
import UIKit

/**
 Instead of having an interface with two methods ( breaking the ISP )
 we could allow the client to decide when to cancel. As we can see here
 we need to keep two states one for the loaded images and one for the
 cancelled and we could move this responsability to the client ( FeedViewController ). We could
 return a task that can be cancelled. Doing so we can have only one method
 that return a cancellable task and we leave the state management to the client
 
 public protocol FeedImageDataLoader {
	 func loadImageData(from url: URL)
	 func cancelImageDataLoad(from url: URL)
 }
 */

public protocol FeedImageDataLoaderTask {
	func cancel()
}

public protocol FeedImageDataLoader {
	func loadImageData(from url: URL) -> FeedImageDataLoaderTask
}

final public class FeedViewController: UITableViewController {
	private var feedLoader: FeedLoader?
	private var imageLoader: FeedImageDataLoader?
	private var isViewAppeared = false
	private var tableModel: [FeedImage] = []
	private var tasks: [IndexPath : FeedImageDataLoaderTask] = [:]
	
	public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
		self.init()
		self.feedLoader = feedLoader
		self.imageLoader = imageLoader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}
	
	public override func viewIsAppearing(_ animated: Bool) {
		super.viewIsAppearing(animated)
		if !isViewAppeared {
			refreshControl?.beginRefreshing()
			isViewAppeared = true
		}
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		feedLoader?.load(completion: { [weak self] result in
			if let feed = try? result.get() {
				self?.tableModel = feed
				self?.tableView.reloadData()
			}
			self?.refreshControl?.endRefreshing()
		})
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
		tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		tasks[indexPath]?.cancel()
		tasks[indexPath] = nil
	}
}
