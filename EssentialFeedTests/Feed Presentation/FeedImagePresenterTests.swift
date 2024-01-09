//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 9/1/24.
//

import EssentialFeed
import XCTest

struct FeedImageViewModel {
	let description: String?
	let location: String?
	let image: Any?
	let isLoading: Bool
	let shouldRetry: Bool

	var hasLocation: Bool {
		return location != nil
	}
}

protocol FeedImageView {
	func display(_ model: FeedImageViewModel)
}

final class FeedImagePresenter {
	private let view: FeedImageView
	
	init(view: FeedImageView) {
		self.view = view
	}
	
	func didStartLoadingImageData(for model: FeedImage) {
		view.display(
			.init(
				description: model.description,
				location: model.location,
				image: nil,
				isLoading: true,
				shouldRetry: false)
		)
	}
}

final class FeedImagePresenterTests: XCTestCase {

	func test_load_doesNotFireAnyMessages() {
		let (_, view) = makeSUT()
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingImageData_displaysLoadingImage() {
		let (sut, view) = makeSUT()
		let image: FeedImage = uniqueImage()
		sut.didStartLoadingImageData(for: image)
		
		let message = view.messages.first
		XCTAssertEqual(view.messages.count, 1)
		XCTAssertEqual(message?.description, image.description)
		XCTAssertEqual(message?.location, image.location)
		XCTAssertEqual(message?.isLoading, true)
		XCTAssertEqual(message?.shouldRetry, false)
		XCTAssertNil(message?.image)
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter(view: view)
		trackForMemoryLeak(view, file: file, line: line)
		trackForMemoryLeak(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
		return FeedImage(
			id: .init(),
			description: description,
			location: location,
			url: url
		)
	}
	
	private final class ViewSpy: FeedImageView {
		private(set) var messages: [FeedImageViewModel] = []
		
		
		func display(_ model: FeedImageViewModel) {
			messages.append(model)
		}
	}
}
