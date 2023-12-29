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


// MARK: - PROD Code
final class FeedViewController: UIViewController {
	private var loader: FeedLoader?
	
	convenience init(loader: FeedLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loader?.load() { _ in }
	}
}

// MARK: - Tests
final class FeedViewControllerTests: XCTestCase {
	
	func test_init_doesNotLoadFeed() {
		let loader = LoaderSpy()
		_ = FeedViewController(loader: loader)
		XCTAssertTrue(loader.loadCallCount == 0, "Exptected 0 but got \(loader.loadCallCount)")
	}
	
	func test_viewDidLoad_loadsFeed() {
		let loader = LoaderSpy()
		let sut = FeedViewController(loader: loader)
	
		sut.loadViewIfNeeded()
		
		XCTAssertTrue(loader.loadCallCount == 1, "Exptected 1 but got \(loader.loadCallCount)")
	}
}

// MARK: - LoaderSpy
class LoaderSpy: FeedLoader {
	private(set) var loadCallCount: Int = 0
	
	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		loadCallCount += 1
	}
}
