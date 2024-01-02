//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 2/1/24.
//

import EssentialFeed
import UIKit

final public class FeedImageCellController {
	private var task: FeedImageDataLoaderTask?
	private var model: FeedImage
	private var imageLoader: FeedImageDataLoader
	
	init(model: FeedImage, imageLoader: FeedImageDataLoader) {
		self.model = model
		self.imageLoader = imageLoader
	}
	
	func view() -> UITableViewCell {
		let cell = FeedImageCell()
		cell.locationContainer.isHidden = (model.location != nil) ? false : true
		cell.locationLabel.text = model.location
		cell.descriptionLabel.text = model.description
		cell.feedImageView.image = nil
		cell.feedImageRetryButton.isHidden = true
		cell.feedImageContainer.startShimmering()
		self.task = makeTask(with: cell)
		
		let loadImage = { [weak self, weak cell] in
			guard let self = self else { return }
			
			self.task = makeTask(with: cell)
		}
		
		cell.onRetry = loadImage
		return cell
	}
	
	func preload() {
		task = imageLoader.loadImageData(from: model.imageURL, completion: { _ in })
	}
	
	private func makeTask(with cell: FeedImageCell?) -> FeedImageDataLoaderTask {
		self.imageLoader.loadImageData(from: model.imageURL) { [weak cell] result in
			let data = try? result.get()
			let image = data.map(UIImage.init) ?? nil
			cell?.feedImageView.image = image
			cell?.feedImageRetryButton.isHidden = (image != nil)
			cell?.feedImageContainer.stopShimmering()
		}
	}
	
	deinit {
		task?.cancel()
	}
}
