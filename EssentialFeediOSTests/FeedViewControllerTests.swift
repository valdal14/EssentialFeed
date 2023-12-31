//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 29/12/23.
//

import EssentialFeed
import EssentialFeediOS
import XCTest
import UIKit


final class FeedViewControllerTests: XCTestCase {
	
	func test_loadFeedActions_requestFeedFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded but got \(loader.loadCallCount)")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expected 1 loading request once user initiates a reload but got \(loader.loadCallCount)")
		
		sut.simulateUserInitiatedFeedReload()
		XCTAssertEqual(loader.loadCallCount, 2, "Expected 2 loading requests once user initiates a reload but got \(loader.loadCallCount)")
		
		sut.simulateUserInitiatedFeedReload()
		XCTAssertEqual(loader.loadCallCount, 3, "Expected 2 loading requests once user initiates a reload but got \(loader.loadCallCount)")
	}
	
	func test_viewIsAppearing_showsLoadingIndicator() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		sut.replaceRefreshControlWithFakeiOS17Support()
		XCTAssertEqual(sut.isShowingLoadingIndicator, false)
		
		sut.simulateFeedLoading()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true)
		
		loader.completeFeedLoading(at: 0)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false)
	}
	
	func test_userInitiatedFeedReload_showsLoadingIndicator() {
		let (sut, loader) = makeSUT()
		
		sut.simulateFeedLoading()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true)
		
		sut.simulateFeedLoading()
		loader.completeFeedLoading(at: 0)
		
		XCTAssertEqual(sut.isShowingLoadingIndicator, false)
		
		/// simulate reload with an error
		sut.simulateUserInitiatedFeedReload()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true)
		loader.completeFeedLoadingWithError(at: 1)
		/// loading spinner is now stopped
		XCTAssertEqual(sut.isShowingLoadingIndicator, false)
		
	}
	
	/**
	 simulateUserInitiatedFeedReload after view is loaded
	 */
	func test_loadCompletion_RenderSuccessfullyLoadedFeedAfterReload() {
		let image0 = makeImage(description: "a description", location: "a location")
		let image1 = makeImage(description: "a description", location: "a location")
		
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0, "Expected 0 Image View but got \(sut.numberOfRenderedFeedImageViews())")
		
		loader.completeFeedLoading(with: [image0], at: 0)
		
		XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 1, "Expected 1 Image View but got \(sut.numberOfRenderedFeedImageViews())")
		
		sut.simulateUserInitiatedFeedReload()
		
		loader.completeFeedLoading(with: [image0, image1], at: 1)
		
		XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2, "Expected 2 Image View but got \(sut.numberOfRenderedFeedImageViews())")
	}
	
	/**
	 Check feedimage data after loading completion
	 */
	func test_loadFeedCompletion_RenderSuccessfullyLoadedFeed() {
		let images = makeFeedImages()
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		loader.completeFeedLoading(with: images, at: 0)
		
		let view = sut.feedImageView(at: 0) as? FeedImageCell
		
		assertThat(sut, and: loader, isRendering: images)
	}
	
	func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let images = makeFeedImages()
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		loader.completeFeedLoading(with: images, at: 0)
		
		let view = sut.feedImageView(at: 0) as? FeedImageCell
		
		assertThat(sut, and: loader, isRendering: images)
		
		/// user initiate a new reload with error
		sut.simulateUserInitiatedFeedReload()
		loader.completeFeedLoadingWithError(at: 1)
		assertThat(sut, and: loader, isRendering: images)
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedViewController(loader: loader)
		trackForMemoryLeak(loader, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
		return FeedImage(
			id: .init(),
			description: description,
			location: location,
			url: url
		)
	}
	
	private func makeFeedImages() -> [FeedImage] {
		let image0 = makeImage(description: "a description", location: "a location")
		let image1 = makeImage(description: nil, location: "another location")
		let image2 = makeImage(description: "another description", location: nil)
		let image3 = makeImage(description: nil, location: nil)
		
		return [image0, image1, image2, image3]
	}
	
	private func expect(sut: FeedViewController, loader: LoaderSpy, images: [FeedImage], at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
		
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
	
	private func assertThat(_ sut: FeedViewController, and loader: LoaderSpy, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
		guard sut.numberOfRenderedFeedImageViews() == feed.count else {
			return XCTFail("Expected \(feed.count) images but got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
		}
		
		expect(sut: sut, loader: loader, images: feed)
	}
	
	// MARK: - LoaderSpy
	private class LoaderSpy: FeedLoader {
		private var completions: [((FeedLoader.Result) -> Void)] = []
		
		var loadCallCount: Int {
			return completions.count
		}
		
		func load(completion: @escaping (FeedLoader.Result) -> Void) {
			completions.append(completion)
		}
		
		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
			completions[index](.success(feed))
		}
		
		func completeFeedLoadingWithError(at index: Int) {
			let error: NSError = NSError(domain: "an error", code: 0)
			completions[index](.failure(error))
		}
	}
}

// MARK: - Fix iOS 17 bug with refreshControl
private class FakeRefreshControl: UIRefreshControl {
	private var _isRefreshing = false
	
	override var isRefreshing: Bool { _isRefreshing }
	
	override func beginRefreshing() {
		_isRefreshing = true
	}
	
	override func endRefreshing() {
		_isRefreshing = false
	}
}

//MARK: - FeedViewController DLSs Helper extension
private extension FeedViewController {
	
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing == true
	}
	
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func simulateFeedLoading() {
		if !isViewLoaded {
			loadViewIfNeeded()
			replaceRefreshControlWithFakeiOS17Support()
		}
		beginAppearanceTransition(true, animated: false)
		endAppearanceTransition()
	}
	
	func replaceRefreshControlWithFakeiOS17Support() {
		let fake = FakeRefreshControl()
		refreshControl?.allTargets.forEach{ target in
			refreshControl?.actions(forTarget: target, forControlEvent:
					.valueChanged)?.forEach { action in
						fake.addTarget(target, action: Selector(action), for: .valueChanged)
					}
		}
		refreshControl = fake
	}
	
	/**
	 Decoupling the tests from implementation details such as
	 the UITableView methods to get the number of row in section
	 that have been rendered. The objective is to test the behaviour
	 not the implementation.
	 */
	func numberOfRenderedFeedImageViews() -> Int {
		return tableView.numberOfRows(inSection: feedItemSection)
	}
	
	func feedImageView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedItemSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var feedItemSection: Int {
		return 0
	}
}

// MARK: - extension UIRefreshControl
private extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach{ target in
			actions(
				forTarget: target,
				forControlEvent: .valueChanged
			)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}


// MARK: - DSL helpers for the FeedImageCell
private extension FeedImageCell {
	var isShowingLocation: Bool {
		!locationContainer.isHidden
	}
	
	var locationText: String? {
		return locationLabel.text
	}
	
	var descriptionText: String? {
		return descriptionLabel.text
	}
}
