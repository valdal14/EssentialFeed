//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 5/1/24.
//

import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
	
	class LoaderSpy: FeedLoader, FeedImageDataLoader {
		
		//MARK: - FeedLoader conformance
		private var feedRequestCompletion: [((FeedLoader.Result) -> Void)] = []
		
		var loadFeedCallCount: Int {
			return feedRequestCompletion.count
		}
		
		func load(completion: @escaping (FeedLoader.Result) -> Void) {
			feedRequestCompletion.append(completion)
		}
		
		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
			feedRequestCompletion[index](.success(feed))
		}
		
		func completeFeedLoadingWithError(at index: Int) {
			let error: NSError = NSError(domain: "an error", code: 0)
			feedRequestCompletion[index](.failure(error))
		}
		
		//MARK: - FeedImageDataLoader conformance
		private(set) var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
		private(set) var cancelImageURLs: [URL] = []
		var loadedImageURLs: [URL] {
			return imageRequests.map { $0.url }
		}
		
		
		private struct TaskSpy: FeedImageDataLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			imageRequests.append((url, completion))
			return TaskSpy { [weak self] in self?.cancelImageURLs.append(url) }
		}
		
		func completeImageLoading(with data: Data = Data(), at index: Int = 0) {
			imageRequests[index].completion(.success(data))
		}
		
		func completeImageLoadingWithError(at index: Int = 0) {
			let error: NSError = NSError(domain: "an error", code: 0)
			imageRequests[index].completion(.failure(error))
		}
	}
}
