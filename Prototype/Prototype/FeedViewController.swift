//
//  FeedViewController.swift
//  Prototype
//
//  Created by Valerio D'ALESSIO on 27/12/23.
//

import UIKit

struct FeedImageViewModel {
	let description: String?
	let location: String?
	let imageName: String
}

class FeedViewController: UITableViewController {
	private var feed: [FeedImageViewModel] = []
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.setContentOffset(
			.init(
				x: 0,
				y: -tableView.contentInset.top
			), animated: false
		)
	}
	
	/**
	 Fix for the refreshControl is not working on iOS 16.1 and above
	 https://academy.essentialdeveloper.com/courses/1112681/lectures/50273453
	 */
	override func viewIsAppearing(_ animated: Bool) {
		refresh()
	}
	
	@IBAction func refresh() {
		refreshControl?.beginRefreshing()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			if self.feed.isEmpty {
				self.feed = FeedImageViewModel.prototypeFeed
				self.tableView.reloadData()
			}
			self.refreshControl?.endRefreshing()
		}
	}
}

// MARK: - FeedViewController - UITableView Helpers
extension FeedViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return feed.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")! as? FeedImageCell else {
			fatalError("Cell is not configured")
		}
		
		let model = feed[indexPath.row]
		cell.configure(with: model)
		return cell
	}
}
