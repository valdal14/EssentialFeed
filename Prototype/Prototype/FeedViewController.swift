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
	let feed: [FeedImageViewModel] = FeedImageViewModel.prototypeFeed
	
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
