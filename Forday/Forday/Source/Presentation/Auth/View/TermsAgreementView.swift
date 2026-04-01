//
//  TermsAgreementView.swift
//  Forday
//
//  Created by Subeen on 3/31/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class TermsAgreementView: UIView {

    // MARK: - UI Components

    // Header
    let backButton = UIButton(type: .system)

    // Title Section
    private let titleLabel = UILabel()

    // All Agreement Section
    private let allAgreementContainerView = UIView()
    let allAgreementCheckbox = UIButton(type: .custom)
    private let allAgreementLabel = UILabel()

    // Individual Items Section
    private let itemsStackView = UIStackView()

    // Item 1: 서비스 이용약관 (필수, 밑줄)
    let serviceTermsCheckbox = UIButton(type: .custom)
    let serviceTermsLabel = UILabel()

    // Item 2: 만 14세 이상 확인 (필수)
    let ageCheckbox = UIButton(type: .custom)
    private let ageLabel = UILabel()

    // Item 3: 개인정보 수집 및 이용 (필수, 밑줄)
    let privacyPolicyCheckbox = UIButton(type: .custom)
    let privacyPolicyLabel = UILabel()

    // Item 4: 게시글 좋아요 알림 (선택)
    let pushConsentCheckbox = UIButton(type: .custom)
    private let pushConsentLabel = UILabel()
    private let pushConsentDescriptionLabel = UILabel()

    // Bottom Button
    let nextButton = UIButton()
    private let bottomGradientView = UIView()

    // MARK: - Properties

    // Combine subjects for checkbox state
    let serviceTermsChecked = CurrentValueSubject<Bool, Never>(false)
    let ageChecked = CurrentValueSubject<Bool, Never>(false)
    let privacyPolicyChecked = CurrentValueSubject<Bool, Never>(false)
    let pushConsentChecked = CurrentValueSubject<Bool, Never>(false)

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension TermsAgreementView {
    private func style() {
        backgroundColor = .neutral50

        // Back Button
        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
        }

        // Title
        titleLabel.do {
            $0.setTextWithTypography("포데이 서비스 이용을 위해\n약관 동의가 필요해요.", style: .header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        // All Agreement Container
        allAgreementContainerView.do {
            $0.backgroundColor = .bg004
            $0.layer.cornerRadius = 16
        }

        allAgreementCheckbox.do {
            $0.setImage(.Onoff.checkboxSquareFalse, for: .normal)
            $0.setImage(.Onoff.checkboxSquareTrue, for: .selected)
        }

        allAgreementLabel.do {
            let text = "전체 동의 (선택항목 포함)"
            let attributedString = NSMutableAttributedString(string: text)

            // "전체 동의" 부분 (body14, neutral900)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral900
            ], range: NSRange(location: 0, length: 5))

            // " (선택항목 포함)" 부분 (body14, neutral600)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral600
            ], range: NSRange(location: 5, length: text.count - 5))

            $0.attributedText = attributedString
        }

        // Items Stack View
        itemsStackView.do {
            $0.axis = .vertical
            $0.spacing = 24
            $0.alignment = .leading
        }

        // Service Terms (밑줄)
        serviceTermsCheckbox.do {
            $0.setImage(.Onoff.checkboxSquareFalse, for: .normal)
            $0.setImage(.Onoff.checkboxSquareTrue, for: .selected)
        }

        serviceTermsLabel.do {
            let text = "서비스 이용약관 동의 (필수)"
            let attributedString = NSMutableAttributedString(string: text)

            // "서비스 이용약관" 부분 (body14, neutral900, 밑줄)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral900,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.neutral900
            ], range: NSRange(location: 0, length: 9))

            // " 동의" 부분 (body14, neutral900, 밑줄 없음)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral900
            ], range: NSRange(location: 9, length: 3))

            // " (필수)" 부분 (body14, neutral600)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral600
            ], range: NSRange(location: 12, length: text.count - 12))

            $0.attributedText = attributedString
            $0.isUserInteractionEnabled = true
        }

        // Age Confirmation
        ageCheckbox.do {
            $0.setImage(.Onoff.checkboxSquareFalse, for: .normal)
            $0.setImage(.Onoff.checkboxSquareTrue, for: .selected)
        }

        ageLabel.do {
            let text = "만 14세 이상 확인 (필수)"
            let attributedString = NSMutableAttributedString(string: text)

            // "만 14세 이상 확인" 부분 (body14, neutral900)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral900
            ], range: NSRange(location: 0, length: 11))

            // " (필수)" 부분 (body14, neutral600)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral600
            ], range: NSRange(location: 11, length: text.count - 11))

            $0.attributedText = attributedString
        }

        // Privacy Policy (밑줄)
        privacyPolicyCheckbox.do {
            $0.setImage(.Onoff.checkboxSquareFalse, for: .normal)
            $0.setImage(.Onoff.checkboxSquareTrue, for: .selected)
        }

        privacyPolicyLabel.do {
            let text = "개인정보 수집 및 이용 동의 (필수)"
            let attributedString = NSMutableAttributedString(string: text)

            // "개인정보 수집 및 이용" 부분 (body14, neutral900, 밑줄)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral900,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.neutral900
            ], range: NSRange(location: 0, length: 13))

            // " 동의" 부분 (body14, neutral900, 밑줄 없음)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral900
            ], range: NSRange(location: 13, length: 3))

            // " (필수)" 부분 (body14, neutral600)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral600
            ], range: NSRange(location: 16, length: text.count - 16))

            $0.attributedText = attributedString
            $0.isUserInteractionEnabled = true
        }

        // Push Consent (선택)
        pushConsentCheckbox.do {
            $0.setImage(.Onoff.checkboxSquareFalse, for: .normal)
            $0.setImage(.Onoff.checkboxSquareTrue, for: .selected)
        }

        pushConsentLabel.do {
            let text = "게시글 좋아요 알림 수신 동의 (선택)"
            let attributedString = NSMutableAttributedString(string: text)

            // "게시글 좋아요 알림 수신 동의" 부분 (body14, neutral900)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral900
            ], range: NSRange(location: 0, length: 17))

            // " (선택)" 부분 (body14, neutral600)
            attributedString.addAttributes([
                .font: TypographyStyle.body14.font,
                .foregroundColor: UIColor.neutral600
            ], range: NSRange(location: 17, length: text.count - 17))

            $0.attributedText = attributedString
        }

        pushConsentDescriptionLabel.do {
            $0.setTextWithTypography("내 게시글에 감정 기록이 달리면 알려드려요.", style: .label10)
            $0.textColor = .neutral500
        }

        // Bottom Gradient
        bottomGradientView.do {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor.white.withAlphaComponent(0).cgColor,
                UIColor.white.cgColor
            ]
            gradientLayer.locations = [0.0, 0.61648]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 88)
            $0.layer.insertSublayer(gradientLayer, at: 0)
        }

        // Next Button
        nextButton.do {
            $0.setTitle("다음", for: .normal)
            $0.setTitleColor(.neutralWhite, for: .normal)
            $0.titleLabel?.font = TypographyStyle.header16.font
            $0.backgroundColor = .action003
            $0.layer.cornerRadius = 12
            $0.isEnabled = false
        }
    }

    private func layout() {
        // Add subviews
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(allAgreementContainerView)
        allAgreementContainerView.addSubview(allAgreementCheckbox)
        allAgreementContainerView.addSubview(allAgreementLabel)
        addSubview(itemsStackView)
        addSubview(bottomGradientView)
        addSubview(nextButton)

        // Create item rows
        let serviceTermsRow = createItemRow(checkbox: serviceTermsCheckbox, label: serviceTermsLabel)
        let ageRow = createItemRow(checkbox: ageCheckbox, label: ageLabel)
        let privacyPolicyRow = createItemRow(checkbox: privacyPolicyCheckbox, label: privacyPolicyLabel)

        // Push consent row (with description)
        let pushConsentRow = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .top
        }
        let pushConsentTextStack = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .leading
        }
        pushConsentTextStack.addArrangedSubview(pushConsentLabel)
        pushConsentTextStack.addArrangedSubview(pushConsentDescriptionLabel)
        pushConsentRow.addArrangedSubview(pushConsentCheckbox)
        pushConsentRow.addArrangedSubview(pushConsentTextStack)

        // Add rows to stack
        itemsStackView.addArrangedSubview(serviceTermsRow)
        itemsStackView.addArrangedSubview(ageRow)
        itemsStackView.addArrangedSubview(privacyPolicyRow)
        itemsStackView.addArrangedSubview(pushConsentRow)

        // Layout constraints
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(23)
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(backButton.snp.bottom).offset(48)
        }

        allAgreementContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.height.equalTo(44)
        }

        allAgreementCheckbox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        allAgreementLabel.snp.makeConstraints {
            $0.leading.equalTo(allAgreementCheckbox.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        itemsStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.top.equalTo(allAgreementContainerView.snp.bottom).offset(20)
        }

        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(88)
        }

        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.width.equalTo(328)
            $0.height.equalTo(56)
        }

        // Checkbox constraints
        [serviceTermsCheckbox, ageCheckbox, privacyPolicyCheckbox, pushConsentCheckbox].forEach {
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(20)
            }
        }
    }

    private func createItemRow(checkbox: UIButton, label: UILabel) -> UIStackView {
        let row = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        row.addArrangedSubview(checkbox)
        row.addArrangedSubview(label)
        return row
    }

    private func setupBindings() {
        // 필수 3개 체크 시 다음 버튼 활성화
        Publishers.CombineLatest3(
            serviceTermsChecked,
            ageChecked,
            privacyPolicyChecked
        )
        .map { $0 && $1 && $2 }
        .sink { [weak self] allRequired in
            self?.nextButton.isEnabled = allRequired
            self?.nextButton.backgroundColor = allRequired ? .action001 : .action003
        }
        .store(in: &cancellables)

        // 전체 동의 체크박스 상태 (4개 모두 체크되면 전체 동의 체크)
        Publishers.CombineLatest4(
            serviceTermsChecked,
            ageChecked,
            privacyPolicyChecked,
            pushConsentChecked
        )
        .map { $0 && $1 && $2 && $3 }
        .sink { [weak self] allChecked in
            self?.allAgreementCheckbox.isSelected = allChecked
        }
        .store(in: &cancellables)
    }
}

// MARK: - Public Methods

extension TermsAgreementView {
    /// 전체 동의 체크박스 토글
    func toggleAllAgreement() {
        let newState = !allAgreementCheckbox.isSelected
        allAgreementCheckbox.isSelected = newState

        serviceTermsCheckbox.isSelected = newState
        ageCheckbox.isSelected = newState
        privacyPolicyCheckbox.isSelected = newState
        pushConsentCheckbox.isSelected = newState

        serviceTermsChecked.send(newState)
        ageChecked.send(newState)
        privacyPolicyChecked.send(newState)
        pushConsentChecked.send(newState)
    }

    /// 개별 체크박스 토글
    func toggleCheckbox(_ checkbox: UIButton, subject: CurrentValueSubject<Bool, Never>) {
        checkbox.isSelected.toggle()
        subject.send(checkbox.isSelected)
    }
}
