//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 2/1/24.
//

import Foundation

public protocol FeedImageDataLoaderTask {
	func cancel()
}

public protocol FeedImageDataLoader {
	typealias Result = Swift.Result<Data, Error>
	func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
