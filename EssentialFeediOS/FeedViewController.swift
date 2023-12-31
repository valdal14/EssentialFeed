//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 30/12/23.
//

import EssentialFeed
import UIKit

final public class FeedViewController: UITableViewController {
	private var loader: FeedLoader?
	private var isViewAppeared = false
	private var tableModel: [FeedImage] = []
	
	public convenience init(loader: FeedLoader) {
		self.init()
		self.loader = loader
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
		loader?.load(completion: { [weak self] result in
			switch result {
			case .success(let feed):
				self?.tableModel = feed
				self?.tableView.reloadData()
				self?.refreshControl?.endRefreshing()
			case .failure(let error):
				break
			}
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
		return cell
	}
}
