//
//  ImageSizeCache.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import UIKit
import Kingfisher

/// 이미지 URL별 크기(width, height)를 캐싱하는 싱글톤 클래스
/// Pinterest 레이아웃에서 이미지 비율에 맞는 셀 높이 계산에 사용
final class ImageSizeCache {

    // MARK: - Singleton

    static let shared = ImageSizeCache()

    private init() {}

    // MARK: - Properties

    private var cache: [String: CGSize] = [:]
    private let queue = DispatchQueue(label: "com.forday.imageSizeCache", attributes: .concurrent)

    // MARK: - Public Methods

    /// 캐시된 이미지 크기 반환
    /// - Parameter url: 이미지 URL
    /// - Returns: 캐시된 크기가 있으면 CGSize, 없으면 nil
    func getSize(for url: String) -> CGSize? {
        return queue.sync {
            cache[url]
        }
    }

    /// 이미지 크기 캐싱
    /// - Parameters:
    ///   - size: 이미지 크기
    ///   - url: 이미지 URL
    func setSize(_ size: CGSize, for url: String) {
        queue.async(flags: .barrier) {
            self.cache[url] = size
        }
    }

    /// URL에서 이미지를 다운로드하고 크기를 캐싱
    /// - Parameters:
    ///   - url: 이미지 URL
    ///   - completion: 완료 콜백 (메인 스레드에서 호출)
    func prefetchSize(for url: String, completion: ((CGSize?) -> Void)? = nil) {
        // 이미 캐시된 경우
        if let cachedSize = getSize(for: url) {
            completion?(cachedSize)
            return
        }

        guard let imageURL = URL(string: url) else {
            completion?(nil)
            return
        }

        // Kingfisher를 사용해 이미지 다운로드 및 크기 추출
        KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
            switch result {
            case .success(let imageResult):
                let size = imageResult.image.size
                self?.setSize(size, for: url)
                DispatchQueue.main.async {
                    completion?(size)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
        }
    }

    /// 여러 URL의 이미지 크기를 비동기로 프리페치
    /// - Parameters:
    ///   - urls: 이미지 URL 배열
    ///   - completion: 모든 프리페치 완료 시 호출되는 콜백
    func prefetchSizes(for urls: [String], completion: (() -> Void)? = nil) {
        let group = DispatchGroup()

        for url in urls {
            guard !url.isEmpty, getSize(for: url) == nil else { continue }

            group.enter()
            prefetchSize(for: url) { _ in
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion?()
        }
    }

    /// 캐시 초기화
    func clearCache() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}
