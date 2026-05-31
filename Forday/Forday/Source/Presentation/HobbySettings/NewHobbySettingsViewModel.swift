//
//  NewHobbySettingsViewModel.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation
import Combine

class NewHobbySettingsViewModel {

    // MARK: - Published Properties

    @Published var progressHobbies: [HobbyItemV2Entity] = []
    @Published var hiddenHobbies: [HobbyItemV2Entity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasChanges: Bool = false
    @Published var isDeletionMode: Bool = false

    // MARK: - UseCases

    private let fetchUseCase: FetchHobbySettingsV2UseCase
    private let updateUseCase: UpdateHobbySettingsV2UseCase
    private let deleteUseCase: DeleteHobbyUseCase
    private let createUseCase: CreateHobbyV2UseCase

    // MARK: - Original Data (for detecting changes)

    private var originalProgressHobbies: [HobbyItemV2Entity] = []
    private var originalHiddenHobbies: [HobbyItemV2Entity] = []

    // MARK: - Initialization

    init(
        fetchUseCase: FetchHobbySettingsV2UseCase,
        updateUseCase: UpdateHobbySettingsV2UseCase,
        deleteUseCase: DeleteHobbyUseCase = DeleteHobbyUseCase(),
        createUseCase: CreateHobbyV2UseCase = CreateHobbyV2UseCase()
    ) {
        self.fetchUseCase = fetchUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.createUseCase = createUseCase
    }

    // MARK: - Public Methods

    /// 취미 목록 조회
    func fetchHobbies() async throws {
        isLoading = true
        errorMessage = nil

        do {
            let settings = try await fetchUseCase.execute()

            await MainActor.run {
                self.progressHobbies = settings.progressHobbyList
                self.hiddenHobbies = settings.hiddenHobbyList
                self.originalProgressHobbies = settings.progressHobbyList
                self.originalHiddenHobbies = settings.hiddenHobbyList
                self.hasChanges = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    /// 취미를 숨김 목록으로 이동
    func moveToHidden(hobbyId: Int) {
        guard let index = progressHobbies.firstIndex(where: { $0.hobbyId == hobbyId }) else { return }
        var hobby = progressHobbies.remove(at: index)
        hobby = HobbyItemV2Entity(
            hobbyId: hobby.hobbyId,
            hobbyName: hobby.hobbyName,
            status: "ARCHIVED",
            imageCode: hobby.imageCode,
            createdAt: hobby.createdAt,
            sequence: hiddenHobbies.count + 1
        )
        hiddenHobbies.append(hobby)
        updateSequences()
        updateHiddenSequences()
        checkForChanges()
    }

    /// 취미를 활성 목록으로 이동
    func moveToProgress(hobbyId: Int) {
        guard let index = hiddenHobbies.firstIndex(where: { $0.hobbyId == hobbyId }) else { return }
        var hobby = hiddenHobbies.remove(at: index)
        hobby = HobbyItemV2Entity(
            hobbyId: hobby.hobbyId,
            hobbyName: hobby.hobbyName,
            status: "IN_PROGRESS",
            imageCode: hobby.imageCode,
            createdAt: hobby.createdAt,
            sequence: progressHobbies.count + 1
        )
        progressHobbies.append(hobby)
        updateHiddenSequences()
        checkForChanges()
    }

    /// 활성 취미 순서 변경
    func moveProgressHobby(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < progressHobbies.count,
              destinationIndex >= 0, destinationIndex < progressHobbies.count else {
            return
        }

        let hobby = progressHobbies.remove(at: sourceIndex)
        progressHobbies.insert(hobby, at: destinationIndex)
        updateSequences()
        checkForChanges()
    }

    /// 숨김 취미 순서 변경
    func moveHiddenHobby(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < hiddenHobbies.count,
              destinationIndex >= 0, destinationIndex < hiddenHobbies.count else {
            return
        }

        let hobby = hiddenHobbies.remove(at: sourceIndex)
        hiddenHobbies.insert(hobby, at: destinationIndex)
        updateHiddenSequences()
        checkForChanges()
    }

    /// 삭제 모드 토글
    func toggleDeletionMode() {
        isDeletionMode.toggle()
    }

    /// 취미 추가
    func addHobby(hobbyName: String) async throws {
        // 취미명 길이 검증
        let trimmedName = hobbyName.trimmingCharacters(in: .whitespaces)
        guard trimmedName.count >= 1 && trimmedName.count <= 20 else {
            throw AppError.validation("취미명은 1자 이상 20자 이하로 입력해주세요.")
        }

        // 현재 취미 개수 확인 (진행 중 + 숨김)
        let totalCount = progressHobbies.count + hiddenHobbies.count
        guard totalCount < 10 else {
            throw AppError.validation("취미는 최대 10개까지 추가할 수 있습니다.")
        }

        isLoading = true
        errorMessage = nil

        do {
            // hobbyInfoId: nil (커스텀 취미)
            _ = try await createUseCase.execute(hobbies: [(hobbyInfoId: nil, hobbyName: trimmedName)])

            // 추가 후 목록 다시 조회
            try await fetchHobbies()

            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    /// 취미 삭제
    func deleteHobby(hobbyId: Int) async throws {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await deleteUseCase.execute(hobbyId: hobbyId)

            await MainActor.run {
                // progressHobbies에서 제거
                if let index = progressHobbies.firstIndex(where: { $0.hobbyId == hobbyId }) {
                    progressHobbies.remove(at: index)
                    updateSequences()
                }
                // hiddenHobbies에서 제거
                if let index = hiddenHobbies.firstIndex(where: { $0.hobbyId == hobbyId }) {
                    hiddenHobbies.remove(at: index)
                    updateHiddenSequences()
                }
                // 원본 데이터도 업데이트
                if let index = originalProgressHobbies.firstIndex(where: { $0.hobbyId == hobbyId }) {
                    originalProgressHobbies.remove(at: index)
                }
                if let index = originalHiddenHobbies.firstIndex(where: { $0.hobbyId == hobbyId }) {
                    originalHiddenHobbies.remove(at: index)
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    /// 저장
    func saveChanges() async throws {
        isLoading = true
        errorMessage = nil

        let progressData = progressHobbies.enumerated().map { (index, hobby) in
            (hobbyId: hobby.hobbyId, sequence: index + 1)
        }
        let hiddenData = hiddenHobbies.enumerated().map { (index, hobby) in
            (hobbyId: hobby.hobbyId, sequence: index + 1)
        }

        do {
            let settings = try await updateUseCase.execute(
                progressHobbies: progressData,
                hiddenHobbies: hiddenData
            )

            await MainActor.run {
                self.progressHobbies = settings.progressHobbyList
                self.hiddenHobbies = settings.hiddenHobbyList
                self.originalProgressHobbies = settings.progressHobbyList
                self.originalHiddenHobbies = settings.hiddenHobbyList
                self.hasChanges = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    // MARK: - Private Methods

    /// sequence 값 업데이트
    private func updateSequences() {
        progressHobbies = progressHobbies.enumerated().map { index, hobby in
            HobbyItemV2Entity(
                hobbyId: hobby.hobbyId,
                hobbyName: hobby.hobbyName,
                status: hobby.status,
                imageCode: hobby.imageCode,
                createdAt: hobby.createdAt,
                sequence: index + 1
            )
        }
    }

    /// 숨김 취미 sequence 값 업데이트
    private func updateHiddenSequences() {
        hiddenHobbies = hiddenHobbies.enumerated().map { index, hobby in
            HobbyItemV2Entity(
                hobbyId: hobby.hobbyId,
                hobbyName: hobby.hobbyName,
                status: hobby.status,
                imageCode: hobby.imageCode,
                createdAt: hobby.createdAt,
                sequence: index + 1
            )
        }
    }

    /// 변경사항 체크
    private func checkForChanges() {
        let progressChanged = !isSameList(progressHobbies, originalProgressHobbies)
        let hiddenChanged = !isSameList(hiddenHobbies, originalHiddenHobbies)
        hasChanges = progressChanged || hiddenChanged
    }

    private func isSameList(_ list1: [HobbyItemV2Entity], _ list2: [HobbyItemV2Entity]) -> Bool {
        guard list1.count == list2.count else { return false }
        return zip(list1, list2).allSatisfy { $0.hobbyId == $1.hobbyId }
    }
}
