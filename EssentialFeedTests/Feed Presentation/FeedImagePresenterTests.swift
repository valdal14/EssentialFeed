//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 9/1/24.
//

import XCTest

final class FeedImagePresenter {
	
}

final class FeedImagePresenterTests: XCTestCase {

	func test_load_doesNotFireAnyMessages() {
		let view = ViewSpy()
		let sut = FeedImagePresenter()
		XCTAssertEqual(view.messages, [])
	}
	
	private final class ViewSpy {
		private(set) var messages: [Message] = []
		
		enum Message: Equatable {
			
		}
	}
}
