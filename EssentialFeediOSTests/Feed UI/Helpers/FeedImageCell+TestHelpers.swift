//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 5/1/24.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
	var isShowingLocation: Bool {
		!locationContainer.isHidden
	}
	
	var isShowingImageLoadingIndicator: Bool {
		return feedImageContainer.isShimmering
	}
	
	var locationText: String? {
		return locationLabel.text
	}
	
	var descriptionText: String? {
		return descriptionLabel.text
	}
	
	var renderedImage: Data? {
		return feedImageView.image?.pngData()
	}
	
	var isShowingRetryAction: Bool {
		return !feedImageRetryButton.isHidden
	}
	
	func simulateRetryAction() {
		feedImageRetryButton.simulateTap()
	}
}
