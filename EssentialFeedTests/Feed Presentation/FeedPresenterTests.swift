//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 9/1/24.
//

import XCTest

// MARK: - Structs
struct FeedErrorViewModel {
	let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
}

struct FeedLoadingViewModel {
	let isLoading: Bool
}


// MARK: Protocols

protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	
	init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.loadingView = loadingView
		self.errorView = errorView
		
	}
	
	func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
}

final class FeedPresenterTests: XCTestCase {

	func test_init_deosNotSendMessagesToView() {
		let (_, view) = makeSUT()
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingFeed_displayesNoErrorMEssageAndStartsLoading() {
		let (sut, view) = makeSUT()
		sut.didStartLoadingFeed()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedPresenter(loadingView: view, errorView: view)
		trackForMemoryLeak(view, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, view)
	}
	
	private final class ViewSpy: FeedErrorView, FeedLoadingView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages: Set<Message> = []
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
	}
}
