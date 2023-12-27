//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import Foundation

public protocol HTTPClient {
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispach to appropriated threads if needed.
	func get(from url: URL, completion: @escaping (Result)-> Void)
}
