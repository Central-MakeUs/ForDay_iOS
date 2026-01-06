//
//  Coordinator.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}