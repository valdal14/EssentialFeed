//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 9/1/24.
//

import Foundation

public struct FeedErrorViewModel {
	public let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> FeedErrorViewModel {
		return FeedErrorViewModel(message: message)
	}
}
