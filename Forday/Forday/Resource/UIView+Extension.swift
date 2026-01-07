//
//  UIView+Extension.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//

import UIKit

extension UIView {
    
    /// Default Gradient
    static func gradient001() -> CAGradientLayer {
        makeGradient(
            colors: [
                UIColor(hex: "FFE6D1"),
                UIColor(hex: "F4A261")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Accent Gradient
    static func gradient002() -> CAGradientLayer {
        makeGradient(
            colors: [
                UIColor(hex: "F4A261"),
                UIColor(hex: "F77F78")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Soft Gradient
    static func gradient003() -> CAGradientLayer {
        makeGradient(
            colors: [
                UIColor(hex: "FFE6D1"),
                UIColor(hex: "F8C8C0")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Soft Accent Gradient
    static func gradient004() -> CAGradientLayer {
        makeGradient(
            colors: [
                UIColor(hex: "FFE6D1"),
                UIColor(hex: "F77F78")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Helper
    private static func makeGradient(colors: [UIColor],
                                    startPoint: GradientPoint,
                                    endPoint: GradientPoint) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint.point
        gradient.endPoint = endPoint.point
        return gradient
    }
    
    func applyGradient(_ gradient: CAGradientLayer) {
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
}

// GradientPoint Enum
enum GradientPoint {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing
    
    var point: CGPoint {
        switch self {
        case .topLeading: return CGPoint(x: 0, y: 0)
        case .top: return CGPoint(x: 0.5, y: 0)
        case .topTrailing: return CGPoint(x: 1, y: 0)
        case .leading: return CGPoint(x: 0, y: 0.5)
        case .center: return CGPoint(x: 0.5, y: 0.5)
        case .trailing: return CGPoint(x: 1, y: 0.5)
        case .bottomLeading: return CGPoint(x: 0, y: 1)
        case .bottom: return CGPoint(x: 0.5, y: 1)
        case .bottomTrailing: return CGPoint(x: 1, y: 1)
        }
    }
}
