//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 3/1/24.
//

import EssentialFeed

struct FeedImageViewModel<Image> {
	let description: String?
	let location: String?
	let image: Image?
	let isLoading: Bool
	let shouldRetry: Bool
	
	var hasLocation: Bool {
		return location != nil
	}
}

