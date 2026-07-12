//
//  MemoSuggestionView.swift
//  Forday
//
//  Created by Subeen on 6/14/26.
//

import UIKit
import SnapKit
import Then

/// 메모 입력 시 키보드 위에 표시되는 추천 문장 버튼 뷰
/// - Note: UITextView의 inputAccessoryView로 사용
class MemoSuggestionView: UIView {

    // MARK: - Properties

    /// 추천 문장 선택 시 호출되는 클로저
    var onSuggestionSelected: ((String) -> Void)?

    /// 추천 문장 목록
    /// - Note: GET /api/v2/records/keyboard-keywords API를 통해 취미별 키워드 조회
    private var suggestions: [String] = []

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension MemoSuggestionView {
    private func style() {
        backgroundColor = .neutral50

        scrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceHorizontal = true
        }

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 7
            $0.alignment = .center
            $0.distribution = .fill
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }

    private func createSuggestionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        config.title = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        config.baseForegroundColor = .neutral800
        config.background.backgroundColor = .clear  // 기본: 배경 없음
        config.background.cornerRadius = 16
        config.background.strokeColor = .stroke001
        config.background.strokeWidth = 1

        // Pretendard Medium 11px (Figma 스펙)
        let font = UIFont(name: FontName.pretendardMedium.rawValue, size: 11) ?? .systemFont(ofSize: 11, weight: .medium)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }

        button.configuration = config
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.background.backgroundColor = button.isSelected ? .neutralWhite : .clear
            button.configuration = config
        }
        button.addTarget(self, action: #selector(suggestionButtonTapped(_:)), for: .touchUpInside)

        return button
    }

    @objc private func suggestionButtonTapped(_ sender: UIButton) {
        guard let title = sender.configuration?.title else { return }
        onSuggestionSelected?(title)
    }
}

// MARK: - Public Methods

extension MemoSuggestionView {
    /// 추천 문장 목록 업데이트
    /// - Parameter suggestions: 추천 문장 배열
    func updateSuggestions(_ suggestions: [String]) {
        self.suggestions = suggestions

        // 기존 버튼들 제거
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 새 버튼들 추가
        for suggestion in suggestions {
            let button = createSuggestionButton(title: suggestion)
            stackView.addArrangedSubview(button)
        }
    }

    /// 기본 높이 반환 (inputAccessoryView 설정용)
    static var defaultHeight: CGFloat {
        return 44
    }
}
