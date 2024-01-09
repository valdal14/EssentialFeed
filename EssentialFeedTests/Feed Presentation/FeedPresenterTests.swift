//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 9/1/24.
//

import EssentialFeed
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

struct FeedViewModel {
	let feed: [FeedImage]
}

// MARK: Protocols

protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
	private let feedView: FeedView
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	
	init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.feedView = feedView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
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
	
	func test_didFinishLoadingFeed_displayFeedsAndStopLoading() {
		let (sut, view) = makeSUT()
		let feed: [FeedImage] = []
		sut.didFinishLoadingFeed(with: feed)
		
		XCTAssertEqual(view.messages, [
			.display(feed: feed),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
		trackForMemoryLeak(view, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, view)
	}
	
	private final class ViewSpy: FeedView, FeedLoadingView, FeedErrorView  {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(feed: [FeedImage])
		}
		
		private(set) var messages: Set<Message> = []
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedViewModel) {
			messages.insert(.display(feed: viewModel.feed))
		}
	}
}
