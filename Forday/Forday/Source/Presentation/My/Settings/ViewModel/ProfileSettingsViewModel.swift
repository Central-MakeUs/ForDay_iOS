//
//  ProfileSettingsViewModel.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import Foundation
import UIKit
import Combine

final class ProfileSettingsViewModel {

    // MARK: - Published Properties

    @Published var profileImage: UIImage?
    @Published var profileImageUrl: String?
    @Published var nickname: String = ""
    @Published var validationResult: NicknameValidationResult = .initial
    @Published var isDuplicateChecked: Bool = false
    @Published var isCompleteButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: AppError?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var initialNickname: String = ""
    private var initialProfileImageUrl: String?
    private var hasImageChanged: Bool = false
    private var shouldResetToDefault: Bool = false

    // MARK: - UseCases

    private let checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase
    private let setNicknameUseCase: SetNicknameUseCase
    private let updateProfileImageUseCase: UpdateProfileImageUseCase
    private let usersRepository: UsersRepositoryInterface

    // MARK: - Initialization

    init(
        checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase = CheckNicknameDuplicateUseCase(),
        setNicknameUseCase: SetNicknameUseCase = SetNicknameUseCase(),
        updateProfileImageUseCase: UpdateProfileImageUseCase = UpdateProfileImageUseCase(),
        usersRepository: UsersRepositoryInterface = UsersRepository()
    ) {
        self.checkNicknameDuplicateUseCase = checkNicknameDuplicateUseCase
        self.setNicknameUseCase = setNicknameUseCase
        self.updateProfileImageUseCase = updateProfileImageUseCase
        self.usersRepository = usersRepository
        bind()
    }

    // MARK: - Binding

    private func bind() {
        // Nickname 변경 시 자동 유효성 검사
        $nickname
            .dropFirst()
            .sink { [weak self] text in
                self?.validateNickname(text)
            }
            .store(in: &cancellables)

        // 완료 버튼 활성화 조건
        Publishers.CombineLatest4($isDuplicateChecked, $validationResult, $nickname, $profileImage)
            .sink { [weak self] isChecked, result, currentNickname, _ in
                guard let self = self else { return }
                self.updateCompleteButtonState(
                    isChecked: isChecked,
                    result: result,
                    currentNickname: currentNickname
                )
            }
            .store(in: &cancellables)
    }

    private func updateCompleteButtonState(isChecked: Bool, result: NicknameValidationResult, currentNickname: String) {
        let nicknameChanged = currentNickname != initialNickname

        // 닉네임이 변경된 경우: 유효성 검사 통과 + 중복확인 완료
        let nicknameCondition: Bool
        if nicknameChanged {
            nicknameCondition = (result == .available) && isChecked
        } else {
            // 닉네임이 변경되지 않은 경우: 이미지만 변경해도 OK
            nicknameCondition = true
        }

        // 변경사항이 있어야 함 (닉네임 변경 또는 이미지 변경)
        let hasChanges = nicknameChanged || hasImageChanged || shouldResetToDefault

        isCompleteButtonEnabled = nicknameCondition && hasChanges
    }

    // MARK: - Public Methods

    /// 초기 프로필 설정 (UserInfo 로드 후 호출)
    func setInitialProfile(nickname: String, profileImageUrl: String?) {
        self.initialNickname = nickname
        self.nickname = nickname
        self.initialProfileImageUrl = profileImageUrl
        self.profileImageUrl = profileImageUrl
        self.isDuplicateChecked = true
        self.hasImageChanged = false
        self.shouldResetToDefault = false
        self.validationResult = .initial
    }

    /// 갤러리에서 선택한 이미지로 변경
    func updateProfileImage(_ image: UIImage) {
        print("📷 updateProfileImage 호출됨 - 이미지 크기: \(image.size)")
        self.profileImage = image
        self.hasImageChanged = true
        self.shouldResetToDefault = false
        print("📷 hasImageChanged: \(self.hasImageChanged), profileImage nil 여부: \(self.profileImage == nil)")
    }

    /// 기본 이미지로 설정
    func resetToDefaultImage() {
        self.profileImage = nil
        self.profileImageUrl = nil
        self.hasImageChanged = true
        self.shouldResetToDefault = true
    }

    /// 닉네임 유효성 검사 (클라이언트 측)
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

        // 한글, 영어, 숫자만 허용
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
                    self.validationResult = .available
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

    /// 프로필 저장
    func saveProfile() async throws {
        print("📷 saveProfile 시작")
        print("📷 hasImageChanged: \(hasImageChanged), shouldResetToDefault: \(shouldResetToDefault), profileImage nil: \(profileImage == nil)")

        await MainActor.run {
            self.isLoading = true
        }

        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }

        // 1. 이미지 변경된 경우
        if hasImageChanged {
            if shouldResetToDefault {
                // 기본 이미지로 설정 (null 전달)
                print("📷 프로필 이미지 기본으로 설정 (null)")
                _ = try await usersRepository.updateProfileImage(profileImageUrl: nil)
            } else if let image = profileImage {
                // 새 이미지 업로드
                print("📷 프로필 이미지 업로드 시작")
                _ = try await updateProfileImageUseCase.execute(image: image)
                print("📷 프로필 이미지 업로드 완료")
            }
        }

        // 2. 닉네임 변경된 경우
        if nickname != initialNickname {
            _ = try await setNicknameUseCase.execute(nickname: nickname)
        }
    }
}
