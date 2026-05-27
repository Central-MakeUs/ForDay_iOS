//
//  TermsAgreementViewController.swift
//  Forday
//
//  Created by Subeen on 3/31/26.
//

import UIKit
import Combine

protocol TermsAgreementCoordinatorDelegate: AnyObject {
    func termsAgreementDidComplete()
    func termsAgreementDidRequestBack()
    func termsAgreementDidRequestTermsDetail(type: TermsType)
}

final class TermsAgreementViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: TermsAgreementCoordinatorDelegate?

    private var termsAgreementView: TermsAgreementView {
        return view as! TermsAgreementView
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = TermsAgreementView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

// MARK: - Setup

extension TermsAgreementViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupActions() {
        // Back Button
        termsAgreementView.backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        // All Agreement Checkbox
        termsAgreementView.allAgreementCheckbox.addTarget(
            self,
            action: #selector(allAgreementCheckboxTapped),
            for: .touchUpInside
        )

        // Individual Checkboxes
        termsAgreementView.serviceTermsCheckbox.addTarget(
            self,
            action: #selector(serviceTermsCheckboxTapped),
            for: .touchUpInside
        )

        termsAgreementView.ageCheckbox.addTarget(
            self,
            action: #selector(ageCheckboxTapped),
            for: .touchUpInside
        )

        termsAgreementView.privacyPolicyCheckbox.addTarget(
            self,
            action: #selector(privacyPolicyCheckboxTapped),
            for: .touchUpInside
        )

        termsAgreementView.pushConsentCheckbox.addTarget(
            self,
            action: #selector(pushConsentCheckboxTapped),
            for: .touchUpInside
        )

        // Label Tap Gestures (밑줄 부분)
        let serviceTermsTap = UITapGestureRecognizer(target: self, action: #selector(serviceTermsLabelTapped))
        termsAgreementView.serviceTermsLabel.addGestureRecognizer(serviceTermsTap)

        let privacyPolicyTap = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelTapped))
        termsAgreementView.privacyPolicyLabel.addGestureRecognizer(privacyPolicyTap)

        // Next Button
        termsAgreementView.nextButton.addTarget(
            self,
            action: #selector(nextButtonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Actions

extension TermsAgreementViewController {
    @objc private func backButtonTapped() {
        coordinator?.termsAgreementDidRequestBack()
    }

    @objc private func allAgreementCheckboxTapped() {
        termsAgreementView.toggleAllAgreement()
    }

    @objc private func serviceTermsCheckboxTapped() {
        termsAgreementView.toggleCheckbox(
            termsAgreementView.serviceTermsCheckbox,
            subject: termsAgreementView.serviceTermsChecked
        )
    }

    @objc private func ageCheckboxTapped() {
        termsAgreementView.toggleCheckbox(
            termsAgreementView.ageCheckbox,
            subject: termsAgreementView.ageChecked
        )
    }

    @objc private func privacyPolicyCheckboxTapped() {
        termsAgreementView.toggleCheckbox(
            termsAgreementView.privacyPolicyCheckbox,
            subject: termsAgreementView.privacyPolicyChecked
        )
    }

    @objc private func pushConsentCheckboxTapped() {
        termsAgreementView.toggleCheckbox(
            termsAgreementView.pushConsentCheckbox,
            subject: termsAgreementView.pushConsentChecked
        )
    }

    @objc private func serviceTermsLabelTapped() {
        coordinator?.termsAgreementDidRequestTermsDetail(type: .termsOfService)
    }

    @objc private func privacyPolicyLabelTapped() {
        coordinator?.termsAgreementDidRequestTermsDetail(type: .privacyPolicy)
    }

    @objc private func nextButtonTapped() {
        // 로컬 저장
        let storage = TermsConsentStorage.shared
        storage.saveConsents(
            serviceConsent: termsAgreementView.serviceTermsChecked.value,
            ageOver14Consent: termsAgreementView.ageChecked.value,
            privateConsent: termsAgreementView.privacyPolicyChecked.value,
            recordPushConsent: termsAgreementView.pushConsentChecked.value
        )

        print("✅ Terms consent saved locally")
        print("   - Service: \(storage.serviceConsent)")
        print("   - Age 14+: \(storage.ageOver14Consent)")
        print("   - Privacy: \(storage.privateConsent)")
        print("   - Push: \(storage.recordPushConsent)")
        print("   - Completed: \(storage.termsConsentCompleted)")

        // TODO: 나중에 POST /terms/consent API 호출

        // 온보딩으로 이동
        coordinator?.termsAgreementDidComplete()
    }
}

#if DEBUG
#Preview {
    TermsAgreementViewController()
}
#endif
