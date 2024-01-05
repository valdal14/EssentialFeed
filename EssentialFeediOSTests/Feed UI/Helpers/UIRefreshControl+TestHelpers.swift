//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Valerio D'ALESSIO on 5/1/24.
//

import UIKit

// MARK: - Fix iOS 17 bug with refreshControl
class FakeRefreshControl: UIRefreshControl {
	private var _isRefreshing = false
	
	override var isRefreshing: Bool { _isRefreshing }
	
	override func beginRefreshing() {
		_isRefreshing = true
	}
	
	override func endRefreshing() {
		_isRefreshing = false
	}
}

//MARK: - FeedViewController DLSs Helper extension


// MARK: - extension UIRefreshControl
extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach{ target in
			actions(
				forTarget: target,
				forControlEvent: .valueChanged
			)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}
