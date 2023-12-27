//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Valerio D'ALESSIO on 27/12/23.
//

import UIKit

final class FeedImageCell: UITableViewCell {
	@IBOutlet private(set) var locationContainer: UIView!
	@IBOutlet private(set) var locationLabel: UILabel!
	@IBOutlet private(set) var feedImageView: UIImageView!
	@IBOutlet private(set) var descriptionLabel: UILabel!
}

// MARK: - Configure the Cell
extension FeedImageCell {
	func configure(with model: FeedImageViewModel) {
		locationLabel.text = model.location
		locationContainer.isHidden = model.location == nil
		descriptionLabel.text = model.description
		descriptionLabel.isHidden = model.description == nil
		fadeIn(UIImage(named: model.imageName))
	}
}

// MARK: - Fake the Asynch loading of the images
extension FeedImageCell {
	override func awakeFromNib() {
		super.awakeFromNib()
		feedImageView.alpha = 0
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		feedImageView.alpha = 0
	}
	
	func fadeIn(_ image: UIImage?) {
		feedImageView.image = image
		
		UIView.animate(
			withDuration: 0.3,
			delay: 0.3) { [weak self] in
				self?.feedImageView.alpha = 1
			}
	}
}
