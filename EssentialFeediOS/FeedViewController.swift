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
		loader?.load() { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}
