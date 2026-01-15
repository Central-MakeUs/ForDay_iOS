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
    
    func applyGradient(_ gradient: AppGradient) {
            layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            let gradientLayer = gradient.makeLayer()
            gradientLayer.frame = bounds
            layer.insertSublayer(gradientLayer, at: 0)
        }

    func applyGradientBorder(
        _ gradient: AppGradient,
        lineWidth: CGFloat,
        cornerRadius: CGFloat
    ) {
        layer.sublayers?
            .filter { $0.name == "GradientBorderLayer" }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = gradient.makeLayer()
        gradientLayer.name = "GradientBorderLayer"
        gradientLayer.frame = bounds
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
            cornerRadius: cornerRadius
        ).cgPath
        
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
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


enum DesignGradient {

    static let gradient001 = AppGradient(
        colors: [
            UIColor(hex: "FFE6D1"),
            UIColor(hex: "F4A261")
        ],
        start: .topLeading,
        end: .bottomTrailing
    )

    static let gradient002 = AppGradient(
        colors: [
            UIColor(hex: "F4A261"),
            UIColor(hex: "F77F78")
        ],
        start: .top,
        end: .bottom
    )

    static let gradient003 = AppGradient(
        colors: [
            UIColor(hex: "FFE6D1"),
            UIColor(hex: "F8C8C0")
        ],
        start: .top,
        end: .bottom
    )
    
    static let gradient004 = AppGradient(
        colors: [
            UIColor(hex: "FFE6D1"),
            UIColor(hex: "F77F78")
        ],
        start: .top,
        end: .bottom
    )
}

struct AppGradient {
    let colors: [UIColor]
    let start: GradientPoint
    let end: GradientPoint

    func makeLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = colors.map { $0.cgColor }
        layer.startPoint = start.point
        layer.endPoint = end.point
        return layer
    }
}
