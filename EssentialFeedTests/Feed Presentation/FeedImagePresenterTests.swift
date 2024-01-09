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
		let (_, view) = makeSUT()
		XCTAssertEqual(view.messages, [])
	}
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter()
		trackForMemoryLeak(view, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, view)
	}
	
	private final class ViewSpy {
		private(set) var messages: [Message] = []
		
		enum Message: Equatable {
			
		}
	}
}
