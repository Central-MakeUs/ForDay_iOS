//
//  TermsResponse.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import Foundation

extension DTO {
    // MARK: - Terms of Service Response
    struct TermsOfServiceResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: TermsOfServiceData
    }

    struct TermsOfServiceData: Codable {
        let title: String
        let version: String
        let sections: [TermsSection]
        let serviceInfo: ServiceInfo
    }

    // MARK: - Privacy Policy Response
    struct PrivacyPolicyResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: PrivacyPolicyData
    }

    struct PrivacyPolicyData: Codable {
        let title: String
        let description: String?
        let version: String
        let sections: [TermsSection]
        let serviceInfo: ServiceInfo
    }

    // MARK: - Common Structures
    struct TermsSection: Codable {
        let sectionNo: Int
        let sectionTitle: String
        let articles: [TermsArticle]
    }

    struct TermsArticle: Codable {
        let articleId: Int
        let clauseNo: Int?
        let content: String
        let items: [TermsItem]?
    }

    struct TermsItem: Codable {
        let itemId: Int
        let itemNo: Int
        let content: String
    }

    struct ServiceInfo: Codable {
        let title: String?
        let description: String?
        let serviceName: String
        let companyName: String
        let email: String
        let representative: String
    }
}
