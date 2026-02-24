//
//  ImageTemplateSelectorViewModel.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit
import Combine
import Photos

final class ImageTemplateSelectorViewModel {

    // MARK: - Error

    private enum ImageTemplateError: LocalizedError {
        case imageLoadFailed
        case photoPermissionDenied
        case photoPermissionNotDetermined
        case saveFailed
        case unknown

        var errorDescription: String? {
            switch self {
            case .imageLoadFailed:
                return "이미지를 불러올 수 없습니다."
            case .photoPermissionDenied:
                return "사진 저장 권한이 필요합니다. 설정에서 권한을 허용해주세요."
            case .photoPermissionNotDetermined:
                return "사진 저장 권한을 확인할 수 없습니다."
            case .saveFailed:
                return "이미지 저장에 실패했습니다."
            case .unknown:
                return "알 수 없는 오류가 발생했습니다."
            }
        }
    }

    // MARK: - Published Properties

    @Published private(set) var activityDetail: ActivityDetail?
    @Published private(set) var templateImage: UIImage?
    @Published private(set) var isLoading = false
    @Published private(set) var saveResult: Result<Void, Error>?

    // MARK: - Properties

    private let imageUrl: String
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(activityDetail: ActivityDetail) {
        self.activityDetail = activityDetail
        self.imageUrl = activityDetail.imageUrl
    }

    // MARK: - Public Methods

    /// 이미지 로드
    func loadImage() {
        guard !imageUrl.isEmpty, let url = URL(string: imageUrl) else { return }

        isLoading = true

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.saveResult = .failure(error)
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    self?.saveResult = .failure(ImageTemplateError.imageLoadFailed)
                    return
                }

                self?.templateImage = image
            }
        }.resume()
    }

    /// 갤러리에 이미지 저장
    func saveToGallery(image: UIImage) {
        isLoading = true

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.performSave(image: image)
                case .denied, .restricted:
                    self?.isLoading = false
                    self?.saveResult = .failure(ImageTemplateError.photoPermissionDenied)
                case .notDetermined:
                    self?.isLoading = false
                    self?.saveResult = .failure(ImageTemplateError.photoPermissionNotDetermined)
                @unknown default:
                    self?.isLoading = false
                    self?.saveResult = .failure(ImageTemplateError.unknown)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func performSave(image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if success {
                    self?.saveResult = .success(())
                } else if let error = error {
                    self?.saveResult = .failure(error)
                } else {
                    self?.saveResult = .failure(ImageTemplateError.saveFailed)
                }
            }
        }
    }
}
