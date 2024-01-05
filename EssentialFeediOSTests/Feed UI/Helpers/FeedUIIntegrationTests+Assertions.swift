//
//  FeedUIIntegrationTests+Assertions.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 5/1/24.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
	
	func expect(sut: FeedViewController, loader: LoaderSpy, images: [FeedImage], at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
		
		for (index, feedImage) in images.enumerated() {
			let view = sut.feedImageView(at: index)
			guard let cellView = view as? FeedImageCell else {
				return XCTFail("Expected \(FeedImageCell.self) instance but got \(String(describing: view)) instead", file: file, line: line)
			}
			let isImageShown = ((feedImage.location != nil) ? true : false)
			XCTAssertEqual(cellView.isShowingLocation, isImageShown, file: file, line: line)
			XCTAssertEqual(cellView.locationText, feedImage.location, file: file, line: line)
			XCTAssertEqual(cellView.descriptionText, feedImage.description, file: file, line: line)
		}
		
		loader.completeFeedLoading(with: images, at: 0)
		
		XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), images.count, "Expected \(images.count) Image View but got \(sut.numberOfRenderedFeedImageViews())", file: file, line: line)
	}
	
	func assertThat(_ sut: FeedViewController, and loader: LoaderSpy, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
		guard sut.numberOfRenderedFeedImageViews() == feed.count else {
			return XCTFail("Expected \(feed.count) images but got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
		}
		
		expect(sut: sut, loader: loader, images: feed)
	}
}
