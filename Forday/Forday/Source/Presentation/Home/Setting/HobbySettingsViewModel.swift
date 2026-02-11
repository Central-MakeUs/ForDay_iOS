//
//  HobbySettingsViewModel.swift
//  Forday
//
//  Created by Subeen on 1/22/26.
//

import Foundation
import Combine

class HobbySettingsViewModel {

    // MARK: - Published Properties

    @Published var currentStatus: HobbyStatus = .inProgress
    @Published var hobbySettings: HobbySettings?
    @Published var inProgressCount: Int = 0
    @Published var archivedCount: Int = 0
    @Published var hobbies: [HobbySetting] = []
    @Published var showAddHobbyCell: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - UseCases

    private let fetchHobbySettingsUseCase: FetchHobbySettingsUseCase
    private let updateHobbyTimeUseCase: UpdateHobbyTimeUseCase
    private let updateExecutionCountUseCase: UpdateExecutionCountUseCase
    private let updateGoalDaysUseCase: UpdateGoalDaysUseCase
    private let updateHobbyStatusUseCase: UpdateHobbyStatusUseCase

    // MARK: - Initialization

    init(
        fetchHobbySettingsUseCase: FetchHobbySettingsUseCase,
        updateHobbyTimeUseCase: UpdateHobbyTimeUseCase,
        updateExecutionCountUseCase: UpdateExecutionCountUseCase,
        updateGoalDaysUseCase: UpdateGoalDaysUseCase,
        updateHobbyStatusUseCase: UpdateHobbyStatusUseCase
    ) {
        self.fetchHobbySettingsUseCase = fetchHobbySettingsUseCase
        self.updateHobbyTimeUseCase = updateHobbyTimeUseCase
        self.updateExecutionCountUseCase = updateExecutionCountUseCase
        self.updateGoalDaysUseCase = updateGoalDaysUseCase
        self.updateHobbyStatusUseCase = updateHobbyStatusUseCase
    }

    // MARK: - Public Methods

    func fetchHobbies(status: HobbyStatus) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let settings = try await fetchHobbySettingsUseCase.execute(hobbyStatus: status)

            await MainActor.run {
                self.hobbySettings = settings
                self.currentStatus = settings.currentHobbyStatus
                self.inProgressCount = settings.inProgressHobbyCount
                self.archivedCount = settings.archivedHobbyCount
                self.hobbies = settings.hobbies
                self.updateShowAddHobbyCell()
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

    func switchSegment(to status: HobbyStatus) async {
        currentStatus = status
        do {
            try await fetchHobbies(status: status)
        } catch {
            // Error already set in fetchHobbies
        }
    }

    func archiveHobby(hobbyId: Int) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await updateHobbyStatusUseCase.execute(hobbyId: hobbyId, hobbyStatus: .archived)
            try await fetchHobbies(status: currentStatus)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    func unarchiveHobby(hobbyId: Int) async throws {
        // Check if already 2 in-progress hobbies
        guard inProgressCount < 2 else {
            let error = NSError(domain: "HobbySettings", code: 1, userInfo: [NSLocalizedDescriptionKey: "이미 진행중인 취미가 2개입니다."])
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }

        isLoading = true
        errorMessage = nil

        do {
            try await updateHobbyStatusUseCase.execute(hobbyId: hobbyId, hobbyStatus: .inProgress)
            try await fetchHobbies(status: currentStatus)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    func updateTime(hobbyId: Int, minutes: Int) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await updateHobbyTimeUseCase.execute(hobbyId: hobbyId, minutes: minutes)
            try await fetchHobbies(status: currentStatus)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    func updateExecutionCount(hobbyId: Int, count: Int) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await updateExecutionCountUseCase.execute(hobbyId: hobbyId, executionCount: count)
            try await fetchHobbies(status: currentStatus)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    func updateGoalDays(hobbyId: Int, isDurationSet: Bool) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await updateGoalDaysUseCase.execute(hobbyId: hobbyId, isDurationSet: isDurationSet)
            try await fetchHobbies(status: currentStatus)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    // MARK: - Private Methods

    private func updateShowAddHobbyCell() {
        showAddHobbyCell = (currentStatus == .inProgress && inProgressCount < 2)
    }
}
