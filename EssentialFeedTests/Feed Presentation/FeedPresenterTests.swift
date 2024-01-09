//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 9/1/24.
//

import XCTest

final class FeedPresenter {
	init(view: Any) {}
}

final class FeedPresenterTests: XCTestCase {

	func test_init_deosNotSendMessagesToView() {
		let view = ViewSpy()
		_ = FeedPresenter(view: view)
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	// MARK: - Helpers
	private final class ViewSpy {
		private(set) var messages: [Any] = []
	}
}
