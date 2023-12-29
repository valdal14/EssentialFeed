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
		let (_, loader) = makeSUT()
		_ = FeedViewController(loader: loader)
		XCTAssertTrue(loader.loadCallCount == 0, "Exptected 0 but got \(loader.loadCallCount)")
	}
	
	func test_viewDidLoad_loadsFeed() {
		let (sut, loader) = makeSUT()
	
		sut.loadViewIfNeeded()
		
		XCTAssertTrue(loader.loadCallCount == 1, "Exptected 1 but got \(loader.loadCallCount)")
	}
	
	// MARK: - Helpers
	func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedViewController(loader: loader)
		trackForMemoryLeak(loader, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, loader)
	}
}

// MARK: - LoaderSpy
class LoaderSpy: FeedLoader {
	private(set) var loadCallCount: Int = 0
	
	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		loadCallCount += 1
	}
}
