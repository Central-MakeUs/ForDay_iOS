//
//  EditProfileViewModel.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation
import UIKit
import Combine

class EditProfileViewModel {

    // MARK: - Published Properties

    @Published var profileImage: UIImage?
    @Published var nickname: String = ""
    @Published var validationResult: NicknameValidationResult = .empty
    @Published var isDuplicateChecked: Bool = false
    @Published var isSaveButtonEnabled: Bool = false
    @Published var error: AppError?

    private var cancellables = Set<AnyCancellable>()
    private var initialNickname: String = ""
    private var hasImageChanged: Bool = false

    // MARK: - UseCases

    private let checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase
    private let setNicknameUseCase: SetNicknameUseCase
    private let updateProfileImageUseCase: UpdateProfileImageUseCase

    // MARK: - Initialization

    init(
        checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase = CheckNicknameDuplicateUseCase(),
        setNicknameUseCase: SetNicknameUseCase = SetNicknameUseCase(),
        updateProfileImageUseCase: UpdateProfileImageUseCase = UpdateProfileImageUseCase()
    ) {
        self.checkNicknameDuplicateUseCase = checkNicknameDuplicateUseCase
        self.setNicknameUseCase = setNicknameUseCase
        self.updateProfileImageUseCase = updateProfileImageUseCase
        bind()
    }

    // MARK: - Methods

    private func bind() {
        // 닉네임 변경 시 자동 유효성 검사
        $nickname
            .sink { [weak self] text in
                self?.validateNickname(text)
            }
            .store(in: &cancellables)

        // 중복 확인 완료 + 변경사항 있을 때 저장 버튼 활성화
        Publishers.CombineLatest3($isDuplicateChecked, $validationResult, $nickname)
            .sink { [weak self] isChecked, result, currentNickname in
                guard let self = self else { return }

                let nicknameChanged = currentNickname != self.initialNickname
                let nicknameValid = (nicknameChanged && isChecked && result == .valid) ||
                                  (!nicknameChanged && result == .valid)

                self.isSaveButtonEnabled = (nicknameValid || !nicknameChanged) &&
                                          (nicknameChanged || self.hasImageChanged)
            }
            .store(in: &cancellables)
    }

    /// 초기 프로필 설정
    func setInitialProfile(image: UIImage?, nickname: String) {
        self.profileImage = image
        self.nickname = nickname
        self.initialNickname = nickname
        self.isDuplicateChecked = true
        self.hasImageChanged = false
    }

    /// 프로필 이미지 변경
    func updateProfileImage(_ image: UIImage) {
        self.profileImage = image
        self.hasImageChanged = true
    }

    /// 닉네임 유효성 검사 (클라이언트 검증)
    private func validateNickname(_ text: String) {
        // 닉네임 변경 시 중복 확인 초기화
        if text != initialNickname {
            isDuplicateChecked = false
        } else {
            isDuplicateChecked = true
        }

        if text.isEmpty {
            validationResult = .empty
            return
        }

        let pattern = "^[가-힣a-zA-Z0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)

        if regex?.firstMatch(in: text, range: range) == nil {
            validationResult = .invalidCharacters
            return
        }

        validationResult = .valid
    }

    /// 중복 확인 (서버 통신)
    func checkDuplicate() async {
        guard validationResult == .valid else { return }
        guard nickname != initialNickname else { return }

        do {
            let isAvailable = try await checkNicknameDuplicateUseCase.execute(nickname: nickname)

            await MainActor.run {
                if isAvailable {
                    self.validationResult = .valid
                    self.isDuplicateChecked = true
                } else {
                    self.validationResult = .duplicate
                    self.isDuplicateChecked = false
                }
            }
        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
            }
        }
    }

    /// 프로필 저장 (이미지 + 닉네임)
    func saveProfile() async throws {
        // 1. 이미지 변경되었으면 업로드
        if hasImageChanged, let image = profileImage {
            _ = try await updateProfileImageUseCase.execute(image: image)
        }

        // 2. 닉네임 변경되었으면 저장
        if nickname != initialNickname {
            _ = try await setNicknameUseCase.execute(nickname: nickname)
        }
    }
}
