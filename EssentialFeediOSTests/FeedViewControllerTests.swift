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
		XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded but got \(loader.loadFeedCallCount)")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected 1 loading request once user initiates a reload but got \(loader.loadFeedCallCount)")
		
		sut.simulateUserInitiatedFeedReload()
		XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected 2 loading requests once user initiates a reload but got \(loader.loadFeedCallCount)")
		
		sut.simulateUserInitiatedFeedReload()
		XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected 2 loading requests once user initiates a reload but got \(loader.loadFeedCallCount)")
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
	
	func test_feedImageView_loadsImageURLWhenVisible() {
		let image0 = makeImage(url: URL(string: "https://url-0.com")!)
		let image1 = makeImage(url: URL(string: "https://url-1.com")!)
		
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [image0, image1])
		
		XCTAssertEqual(loader.loadedImageURLs, [], "Expected no images URL request until cell views become visible")
		
		sut.simulateFeedImageViewVisible(at: 0)
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expect first image URL request once first cell view become visible")
		
		sut.simulateFeedImageViewVisible(at: 1)
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expect both image URL requests once both cells view become visible")
	}
	
	func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
		let image0 = makeImage(url: URL(string: "https://url-0.com")!)
		let image1 = makeImage(url: URL(string: "https://url-1.com")!)
		
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [image0, image1])
		
		XCTAssertEqual(loader.cancelImageURLs, [], "Expected no cancelled image URL request until cell views is not visible")
		
		sut.simulateFeedImageViewNotVisible(at: 0)
		XCTAssertEqual(loader.cancelImageURLs, [image0.imageURL], "Expect 1 cancel image URL request once first cell view is not visible")
		
		sut.simulateFeedImageViewNotVisible(at: 1)
		XCTAssertEqual(loader.cancelImageURLs, [image0.imageURL, image1.imageURL], "Expect 2 cancels image URL requests once both cells view are not visible")
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
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
	private class LoaderSpy: FeedLoader, FeedImageDataLoader {
		
		//MARK: - FeedLoader conformance
		private var feedRequestCompletion: [((FeedLoader.Result) -> Void)] = []
		
		var loadFeedCallCount: Int {
			return feedRequestCompletion.count
		}
		
		func load(completion: @escaping (FeedLoader.Result) -> Void) {
			feedRequestCompletion.append(completion)
		}
		
		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
			feedRequestCompletion[index](.success(feed))
		}
		
		func completeFeedLoadingWithError(at index: Int) {
			let error: NSError = NSError(domain: "an error", code: 0)
			feedRequestCompletion[index](.failure(error))
		}
		
		//MARK: - FeedImageDataLoader conformance
		private(set) var loadedImageURLs: [URL] = []
		private(set) var cancelImageURLs: [URL] = []
		
		private struct TaskSpy: FeedImageDataLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		func loadImageData(from url: URL) -> FeedImageDataLoaderTask {
			loadedImageURLs.append(url)
			return TaskSpy { [weak self] in self?.cancelImageURLs.append(url) }
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
	
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
		/// instanciate the feedImageView(at row: Int)
		/// that creates images from the data source
		return feedImageView(at: index) as? FeedImageCell
	}
	
	func simulateFeedImageViewNotVisible(at row: Int) {
		let view = simulateFeedImageViewVisible(at: row)
		
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedItemSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
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
