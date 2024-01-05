//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 29/12/23.
//

import EssentialFeed
import EssentialFeediOS
import XCTest
import UIKit


final class FeedUIIntegrationTests: XCTestCase {
	
	func test_feedView_hasTitle() {
		let (sut, _) = makeSUT()
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
	}
	
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
		
		assertThat(sut, and: loader, isRendering: images)
	}
	
	func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let images = makeFeedImages()
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		loader.completeFeedLoading(with: images, at: 0)
		
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
	
	func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [makeImage(), makeImage()])
		
		let view0 = sut.simulateFeedImageViewVisible(at: 0)
		let view1 = sut.simulateFeedImageViewVisible(at: 1)
		
		XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Exptected loading image indicator while loading the image")
		XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Exptected loading image indicator while loading the image")
		
		loader.completeImageLoading(at: 0)
		XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Exptected no loading image indicator")
		XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Exptected loading image indicator state with no changes while the image is still loading")
		
		loader.completeImageLoading(at: 1)
		XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Exptected no loading image indicator")
		XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Exptected no loading image indicator")
		
	}
	
	func test_feedImageView_rendersImageLoadedFromURL() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [makeImage(), makeImage()])
		
		let view0 = sut.simulateFeedImageViewVisible(at: 0)
		let view1 = sut.simulateFeedImageViewVisible(at: 1)
		XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
		XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
		
		let imageData0 = UIImage.make(withColor: .red).pngData()!
		loader.completeImageLoading(with: imageData0, at: 0)
		XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
		XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
		
		let imageData1 = UIImage.make(withColor: .blue).pngData()!
		loader.completeImageLoading(with: imageData1, at: 1)
		XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
		XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
	}
	
	func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [makeImage(), makeImage()])
		
		let view0 = sut.simulateFeedImageViewVisible(at: 0)
		let view1 = sut.simulateFeedImageViewVisible(at: 1)
		XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
		XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
		
		let imageData = UIImage.make(withColor: .red).pngData()!
		loader.completeImageLoading(with: imageData, at: 0)
		XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
		XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
		
		loader.completeImageLoadingWithError(at: 1)
		XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
		XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
	}
	
	func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [makeImage()])
		
		let view = sut.simulateFeedImageViewVisible(at: 0)
		XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
		
		let invalidImageData = Data("invalid image data".utf8)
		loader.completeImageLoading(with: invalidImageData, at: 0)
		XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
	}
	
	func test_feedImageViewRetryAction_retriesImageLoad() {
		let image0 = makeImage(url: URL(string: "http://url-0.com")!)
		let image1 = makeImage(url: URL(string: "http://url-1.com")!)
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [image0, image1])
		
		let view0 = sut.simulateFeedImageViewVisible(at: 0)
		let view1 = sut.simulateFeedImageViewVisible(at: 1)
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected two image URL request for the two visible views")
		
		loader.completeImageLoadingWithError(at: 0)
		loader.completeImageLoadingWithError(at: 1)
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected only two image URL requests before retry action")
		
		view0?.simulateRetryAction()
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL], "Expected third imageURL request after first view retry action")
		
		view1?.simulateRetryAction()
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL], "Expected fourth imageURL request after second view retry action")
	}
	
	func test_feedImageView_preloadsImageURLWhenNearVisible() {
		let image0 = makeImage(url: URL(string: "http://url-0.com")!)
		let image1 = makeImage(url: URL(string: "http://url-1.com")!)
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [image0, image1])
		XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
		
		sut.simulateFeedImageViewNearVisible(at: 0)
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expected first image URL request once first image is near visible")
		
		sut.simulateFeedImageViewNearVisible(at: 1)
		XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected second image URL request once second image is near visible")
	}
	
	func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
		let image0 = makeImage(url: URL(string: "http://url-0.com")!)
		let image1 = makeImage(url: URL(string: "http://url-1.com")!)
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [image0, image1])
		XCTAssertEqual(loader.cancelImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
		
		sut.simulateFeedImageViewNotNearVisible(at: 0)
		XCTAssertEqual(loader.cancelImageURLs, [image0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
		
		sut.simulateFeedImageViewNotNearVisible(at: 1)
		XCTAssertEqual(loader.cancelImageURLs, [image0.imageURL, image1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
	}
	
	func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [makeImage()])
		
		let view = sut.simulateFeedImageViewNotVisible(at: 0)
		loader.completeImageLoading(with: anyImageData())
		
		XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
	}
	
	func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for the background queue")
		
		DispatchQueue.global().async {
			loader.completeFeedLoading(at: 0)
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
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
	
	private func anyImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
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
		private(set) var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
		private(set) var cancelImageURLs: [URL] = []
		var loadedImageURLs: [URL] {
			return imageRequests.map { $0.url }
		}
		
		
		private struct TaskSpy: FeedImageDataLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			imageRequests.append((url, completion))
			return TaskSpy { [weak self] in self?.cancelImageURLs.append(url) }
		}
		
		func completeImageLoading(with data: Data = Data(), at index: Int = 0) {
			imageRequests[index].completion(.success(data))
		}
		
		func completeImageLoadingWithError(at index: Int = 0) {
			let error: NSError = NSError(domain: "an error", code: 0)
			imageRequests[index].completion(.failure(error))
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
	
	@discardableResult
	func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: row)
		
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedItemSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
		
		return view
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
	
	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedItemSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}
	
	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewNearVisible(at: row)
		
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedItemSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
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

//MARK: - UIButton extension
private extension UIButton {
	func simulateTap() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
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

// MARK: - UIImage extension
private extension UIImage {
	static func make(withColor color: UIColor) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		let format = UIGraphicsImageRendererFormat()
		format.scale = 1
		
		return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
			color.setFill()
			rendererContext.fill(rect)
		}
	}
}
