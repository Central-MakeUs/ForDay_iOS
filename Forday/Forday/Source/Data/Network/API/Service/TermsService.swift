//
//  TermsService.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import Foundation
import Moya

final class TermsService {

    private let provider: MoyaProvider<TermsTarget>

    init(provider: MoyaProvider<TermsTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }

    // MARK: - 서비스 이용약관 조회

    func fetchTermsOfService() async throws -> DTO.TermsOfServiceData {
        let response: DTO.TermsOfServiceResponse = try await provider.request(.fetchTermsOfService)
        return response.data
    }

    // MARK: - 개인정보 처리방침 조회

    func fetchPrivacyPolicy() async throws -> DTO.PrivacyPolicyData {
        let response: DTO.PrivacyPolicyResponse = try await provider.request(.fetchPrivacyPolicy)
        return response.data
    }
}
