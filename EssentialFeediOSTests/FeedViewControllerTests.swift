//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 29/12/23.
//

import EssentialFeed
import XCTest
import UIKit


// MARK: - PROD Code
final class FeedViewController: UITableViewController {
	private var loader: FeedLoader?
	private var isViewAppeared = false
	
	convenience init(loader: FeedLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}
	
	override func viewIsAppearing(_ animated: Bool) {
		super.viewIsAppearing(animated)
		if !isViewAppeared {
			refreshControl?.beginRefreshing()
			isViewAppeared = true
		}
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		loader?.load() { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}

// MARK: - Tests
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
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedViewController(loader: loader)
		trackForMemoryLeak(loader, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, loader)
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
		
		func completeFeedLoading(at index: Int) {
			completions[index](.success([]))
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

//MARK: - FeedViewController extension
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
}

// MARK: - extension UIRefreshControl
private extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach{ target in
			actions(forTarget: target, forControlEvent:
					.valueChanged)?.forEach {
						(target as NSObject).perform(Selector($0))
					}
		}
	}
}
