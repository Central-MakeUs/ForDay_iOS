//
//  UIImage+Extension.swift
//  Forday
//
//  Created by Subeen on 2/23/26.
//

import UIKit

extension UIImage {
    /// 이미지를 지정된 크기로 리사이즈
    /// - Parameter size: 목표 크기
    /// - Returns: 리사이즈된 이미지
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
