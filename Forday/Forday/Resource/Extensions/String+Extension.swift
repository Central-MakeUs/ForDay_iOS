//
//  String+Extension.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import Foundation

extension String {
    /// Truncates the string to specified max length with ellipsis
    /// - Parameter maxLength: Maximum number of characters before truncation
    /// - Returns: Truncated string with "..." if longer than maxLength, otherwise original string
    func truncated(maxLength: Int) -> String {
        if self.count > maxLength {
            let index = self.index(self.startIndex, offsetBy: maxLength)
            return String(self[..<index]) + "..."
        }
        return self
    }

    /// 날짜 문자열을 템플릿용 포맷으로 변환
    /// - Returns: "2026.01.11. (토)" 형식의 문자열
    /// - Note: "2026-01-11 12:06" 또는 "2026-01-11" 형식 입력 지원
    func toTemplateDate() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "ko_KR")

        // "yyyy-MM-dd HH:mm" 형식 시도
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var date = inputFormatter.date(from: self)

        // 실패 시 "yyyy-MM-dd" 형식 시도
        if date == nil {
            inputFormatter.dateFormat = "yyyy-MM-dd"
            date = inputFormatter.date(from: self)
        }

        guard let parsedDate = date else { return self }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd. (E)"
        outputFormatter.locale = Locale(identifier: "ko_KR")

        return outputFormatter.string(from: parsedDate)
    }
}
