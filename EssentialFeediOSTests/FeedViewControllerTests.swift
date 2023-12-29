//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 29/12/23.
//

import XCTest
@testable import EssentialFeediOS

// MARK: - PROD Code
class FeedViewController {
	
	convenience init(loader: LoaderSpy) {
		self.init()
	}
}

// MARK: - Tests
final class FeedViewControllerTests: XCTestCase {
	
	func test_init_doesNotLoadFeed() {
		let loader = LoaderSpy()
		_ = FeedViewController(loader: loader)
		XCTAssertTrue(loader.loadCallCount == 0, "Exptected 0 but got \(loader.loadCallCount)")
	}
}

// MARK: - LoaderSpy
class LoaderSpy {
	private(set) var loadCallCount: Int = 0
}
