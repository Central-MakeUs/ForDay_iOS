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

    // MARK: - UseCases

    private let fetchUseCase: FetchHobbySettingsV2UseCase
    private let updateUseCase: UpdateHobbySettingsV2UseCase

    // MARK: - Original Data (for detecting changes)

    private var originalProgressHobbies: [HobbyItemV2Entity] = []
    private var originalHiddenHobbies: [HobbyItemV2Entity] = []

    // MARK: - Initialization

    init(
        fetchUseCase: FetchHobbySettingsV2UseCase,
        updateUseCase: UpdateHobbySettingsV2UseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.updateUseCase = updateUseCase
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
        return zip(list1, list2).allSatisfy { $0.hobbyId == $1.hobbyId && $0.sequence == $1.sequence }
    }
}
