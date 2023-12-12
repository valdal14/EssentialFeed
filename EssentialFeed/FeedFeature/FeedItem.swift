//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Valerio D'ALESSIO on 12/12/23.
//

import Foundation

public struct FeedItem: Equatable {
   let id: UUID
   let description: String?
   let location: String?
   let imageURL: URL
}
