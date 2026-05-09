//
//  SimpleHobbySelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//

import Foundation
import Combine

class SimpleHobbySelectionViewModel {

    // MARK: - Published Properties

    @Published var selectedHobbies: Set<String> = []
    @Published var isNextButtonEnabled: Bool = false
    @Published var hobbyCards: [HobbyCard] = []

    // MARK: - Properties

    /// 취미 목록 (서버에서 가져온 HobbyCard의 이름만 추출)
    var hobbies: [String] {
        return hobbyCards.map { $0.name }
    }

    private let createHobbyV2UseCase: CreateHobbyV2UseCase
    private let fetchAppMetadataUseCase: FetchAppMetadataUseCase

    // MARK: - Methods

    init(
        createHobbyV2UseCase: CreateHobbyV2UseCase = CreateHobbyV2UseCase(),
        fetchAppMetadataUseCase: FetchAppMetadataUseCase = FetchAppMetadataUseCase()
    ) {
        self.createHobbyV2UseCase = createHobbyV2UseCase
        self.fetchAppMetadataUseCase = fetchAppMetadataUseCase
        // 선택 상태가 변경될 때마다 다음 버튼 활성화 여부 업데이트
        setupBindings()
    }

    private func setupBindings() {
        $selectedHobbies
            .map { !$0.isEmpty }
            .assign(to: &$isNextButtonEnabled)
    }

    /// 취미 선택/해제 토글
    func toggleHobby(_ hobby: String) {
        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else {
            selectedHobbies.insert(hobby)
        }
    }

    /// 특정 취미가 선택되었는지 확인
    func isSelected(_ hobby: String) -> Bool {
        return selectedHobbies.contains(hobby)
    }

    /// 커스텀 취미 추가
    func addCustomHobby(_ hobbyName: String) {
        // 중복 체크
        guard !hobbyCards.contains(where: { $0.name == hobbyName }) else {
            return
        }

        // HobbyCard에 추가 (id는 nil, imageAsset은 한글명 매핑 시도 후 실패하면 default)
        let imageAsset = HobbyImageAsset(hobbyName: hobbyName) ?? .default
        let customHobbyCard = HobbyCard(
            id: nil,
            name: hobbyName,
            description: "",
            imageAsset: imageAsset
        )
        hobbyCards.append(customHobbyCard)

        // 선택 상태로 추가
        selectedHobbies.insert(hobbyName)
    }

    /// 서버에서 취미 기본 정보 가져오기
    func fetchHobbyInfo() async throws {
        let metadata = try await fetchAppMetadataUseCase.execute()

        await MainActor.run {
            self.hobbyCards = metadata.hobbyCards
        }
    }

    /// 선택한 취미들로 v2 API 호출
    func createHobbies() async throws -> [Int] {
        // selectedHobbies를 [(hobbyInfoId, hobbyName)] 형태로 변환
        let hobbyTuples: [(hobbyInfoId: Int?, hobbyName: String)] = selectedHobbies.map { hobbyName in
            // 서버에서 가져온 HobbyCard에서 hobbyInfoId 찾기
            let hobbyCard = hobbyCards.first { $0.name == hobbyName }
            return (hobbyInfoId: hobbyCard?.id, hobbyName: hobbyName)
        }

        return try await createHobbyV2UseCase.execute(hobbies: hobbyTuples)
    }
}
