//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import Foundation

public enum HTTPClientResult {
	case success(HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void)
}

public final class RemoteFeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Error) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .success(let response):
				if response.statusCode == 200 {
					break
				} else {
					completion(.invalidData)
				}
			case .failure:
				completion(.connectivity)
			}
		}
	}
}
