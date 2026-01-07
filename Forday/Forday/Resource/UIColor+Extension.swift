//
//  Color.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//

import UIKit

extension UIColor {
    
    // Primary
    static let primary001 = UIColor(hex: "F4A261")       /// F4A261
    static let primary002 = UIColor(hex: "FFE6D1")       /// FFE6D1
    static let primary003 = UIColor(hex: "FFF1E6")       /// FFF1E6
    
    // Secondary
    static let secondary001 = UIColor(hex: "F77F78")       /// F77F78
    static let secondary002 = UIColor(hex: "F8C8C0")       /// F8C8C0
    static let secondary003 = UIColor(hex: "F25F59")       /// F25F59
    
    // Action
    static let action001 = UIColor(hex: "EE9449")       /// EE9449
    static let action002 = UIColor(hex: "DB8843")       /// DB8843
    static let action003 = UIColor(hex: "E5E5E5")       /// E5E5E5
    
    // Neutral
    static let neutralWhite = UIColor(hex: "FFFFFF")    /// FFFFFF
    static let neutral50 = UIColor(hex: "F9F9F9")       /// F9F9F9
    static let neutral100 = UIColor(hex: "F2F2F2")       /// F2F2F2
    static let neutral200 = UIColor(hex: "E5E5E5")       /// E5E5E5
    static let neutral300 = UIColor(hex: "D1D1D1")       /// D1D1D1
    static let neutral400 = UIColor(hex: "B5B5B5")       /// B5B5B5
    static let neutral500 = UIColor(hex: "9E9E9E")       /// 9E9E9E
    static let neutral600 = UIColor(hex: "7A7A7A")       /// 7A7A7A
    static let neutral700 = UIColor(hex: "5A5A5A")       /// 5A5A5A
    static let neutral800 = UIColor(hex: "3A3A3A")       /// 3A3A3A
    static let neutral900 = UIColor(hex: "1E1E1E")       /// 1E1E1E
    static let neutralBlack = UIColor(hex: "000000")    /// 000000
    
    // Background
    static let bg001 = UIColor(hex: "FFFFFF")    /// FFFFFF
    static let bg002 = UIColor(hex: "F9F9F9")    /// F9F9F9
    static let bg003 = UIColor(hex: "F2F2F2")    /// F2F2F2
    static let bg004 = UIColor(hex: "FFF5EE")    /// FFF5EE
    
    // Stroke
    static let stroke001 = UIColor.neutral200
    static let stroke002 = UIColor.neutral300
    static let stroke003 = UIColor.neutral400
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat((rgb >> 0) & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
