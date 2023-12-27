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
	let viewModel: [FeedImageViewModel] = FeedImageViewModel.prototypeFeed
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
	}
}
