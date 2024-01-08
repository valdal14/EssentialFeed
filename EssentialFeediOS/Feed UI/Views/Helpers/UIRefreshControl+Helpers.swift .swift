//
//  UIRefreshControl+Helpers.swift .swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 8/1/24.
//

import UIKit

extension UIRefreshControl {
	func update(isRefreshing: Bool) {
		isRefreshing ? beginRefreshing() : endRefreshing()
	}
}
