//
//  AIActivityItems.swift
//  Forday
//
//  Created by Subeen on 2/23/26.
//

import Foundation

struct AIActivityItemsResult {
    let message: String
    let hobbyId: Int
    let hobbyName: String
    let activityItems: [AIActivityItem]
}

struct AIActivityItem {
    let itemId: Int
    let content: String
    let description: String
}
