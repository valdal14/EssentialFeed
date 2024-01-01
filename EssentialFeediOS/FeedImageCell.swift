//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 30/12/23.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
	public let locationContainer = UIView()
	public let locationLabel = UILabel()
	public let descriptionLabel = UILabel()
	public let feedImageContainer = UIView()
	public let feedImageView = UIImageView()
	/// configure the button to retry
	private(set) public lazy var feedImageRetryButton: UIButton = {
		let button = UIButton()
		button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
		return button
	}()
	
	var onRetry: (() -> Void)?
	
	@objc private func retryButtonTapped() {
		onRetry?()
	}
}
