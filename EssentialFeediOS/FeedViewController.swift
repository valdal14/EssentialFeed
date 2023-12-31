//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 30/12/23.
//

import EssentialFeed
import UIKit

public protocol FeedImageDataLoader {
	func loadImageData(from url: URL)
	func cancelImageDataLoad(from url: URL)
}

final public class FeedViewController: UITableViewController {
	private var feedLoader: FeedLoader?
	private var imageLoader: FeedImageDataLoader?
	private var isViewAppeared = false
	private var tableModel: [FeedImage] = []
	
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
		imageLoader?.loadImageData(from: cellModel.imageURL)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cellModel = tableModel[indexPath.row]
		imageLoader?.cancelImageDataLoad(from: cellModel.imageURL)
	}
}
