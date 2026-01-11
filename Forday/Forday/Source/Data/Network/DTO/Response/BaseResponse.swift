//
//  BaseResponse.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation

protocol BaseResponse: Decodable {
    associatedtype DataType: Decodable
    var status: Int { get }
    var success: Bool { get }
    var data: DataType { get }
}
