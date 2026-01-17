//
//  OthersActivity.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

struct OthersActivityResult {
    let message: String
    let activities: [OthersActivity]
}

struct OthersActivity {
    let id: Int
    let content: String
}
