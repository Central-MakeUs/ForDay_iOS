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

    /// 이미지를 정방형으로 크롭 (중앙 기준)
    /// - Returns: 정방형으로 크롭된 이미지
    func croppedToSquare() -> UIImage {
        let originalWidth = size.width
        let originalHeight = size.height
        let sideLength = min(originalWidth, originalHeight)

        let xOffset = (originalWidth - sideLength) / 2
        let yOffset = (originalHeight - sideLength) / 2

        let cropRect = CGRect(
            x: xOffset * scale,
            y: yOffset * scale,
            width: sideLength * scale,
            height: sideLength * scale
        )

        guard let cgImage = cgImage?.cropping(to: cropRect) else {
            return self
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }

    /// 이미지를 지정된 비율로 정방형 크롭 후 리사이즈
    /// - Parameter targetSize: 목표 크기
    /// - Returns: 정방형으로 크롭 후 리사이즈된 이미지
    func croppedToSquare(targetSize: CGFloat) -> UIImage {
        let squareImage = croppedToSquare()
        return squareImage.resized(to: CGSize(width: targetSize, height: targetSize))
    }
}
