//
//  XCTTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by Valerio D'ALESSIO on 13/12/23.
//

import XCTest

extension XCTestCase {
	func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance of should have been decallocated to avoid potential memory leak", file: file, line: line)
		}
	}
}
