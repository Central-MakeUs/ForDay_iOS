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
    @Published private(set) var shouldOpenSettings = false

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

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.performSave(image: image)
                case .denied, .restricted:
                    self?.isLoading = false
                    self?.shouldOpenSettings = true
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

    /// 설정 열기 상태 리셋
    func resetOpenSettingsState() {
        shouldOpenSettings = false
    }

    // MARK: - Private Methods

    private static let albumName = "포데이"

    private func performSave(image: UIImage) {
        // 1. Forday 앨범 찾기 또는 생성
        findOrCreateFordayAlbum { [weak self] album in
            guard let self = self else { return }

            guard let album = album else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.saveResult = .failure(ImageTemplateError.saveFailed)
                }
                return
            }

            // 2. 앨범에 이미지 저장
            self.saveImageToAlbum(image: image, album: album)
        }
    }

    private func findOrCreateFordayAlbum(completion: @escaping (PHAssetCollection?) -> Void) {
        // 기존 Forday 앨범 찾기
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", Self.albumName)
        let collections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: fetchOptions
        )

        if let existingAlbum = collections.firstObject {
            completion(existingAlbum)
            return
        }

        // 앨범이 없으면 생성
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges {
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: Self.albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        } completionHandler: { success, _ in
            guard success, let placeholder = albumPlaceholder else {
                completion(nil)
                return
            }

            let fetchResult = PHAssetCollection.fetchAssetCollections(
                withLocalIdentifiers: [placeholder.localIdentifier],
                options: nil
            )
            completion(fetchResult.firstObject)
        }
    }

    private func saveImageToAlbum(image: UIImage, album: PHAssetCollection) {
        // PNG 데이터로 변환
        guard let pngData = image.pngData() else {
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.saveResult = .failure(ImageTemplateError.saveFailed)
            }
            return
        }

        PHPhotoLibrary.shared().performChanges {
            // PNG 형식으로 이미지 에셋 생성
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: pngData, options: nil)

            guard let assetPlaceholder = creationRequest.placeholderForCreatedAsset else { return }

            // 앨범에 에셋 추가
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            albumChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
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
