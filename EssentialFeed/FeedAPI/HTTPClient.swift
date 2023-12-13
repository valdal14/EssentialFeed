//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import Foundation

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void)
}
