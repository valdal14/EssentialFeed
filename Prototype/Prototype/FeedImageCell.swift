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

extension FeedImageCell {
	func configure(with model: FeedImageViewModel) {
		locationLabel.text = model.location
		locationContainer.isHidden = model.location == nil
		descriptionLabel.text = model.description
		descriptionLabel.isHidden = model.description == nil
		feedImageView.image = UIImage(named: model.imageName)
	}
}
