//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 8/1/24.
//

import Foundation

struct FeedErrorViewModel {
	let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> FeedErrorViewModel {
		return FeedErrorViewModel(message: message)
	}
}
