//
//  CoverImageOptionSheet.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class CoverImageOptionSheet: UIViewController {

    // MARK: - Properties

    private let hobbyName: String
    private let onGallerySelected: () -> Void
    private let onActivitySelected: () -> Void

    // MARK: - UI Components

    private let dimmerView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let optionsStackView = UIStackView()
    private let galleryOptionCard = OptionCardView()
    private let activityOptionCard = OptionCardView()
    private let bottomButtonView = UIView()
    private let bottomGradientView = UIView()
    private let confirmButton = UIButton(type: .system)

    private var selectedOption: OptionType?

    private enum OptionType {
        case gallery
        case activity
    }

    // MARK: - Initialization

    init(
        hobbyName: String,
        onGallerySelected: @escaping () -> Void,
        onActivitySelected: @escaping () -> Void
    ) {
        self.hobbyName = hobbyName
        self.onGallerySelected = onGallerySelected
        self.onActivitySelected = onActivitySelected
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupActions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentation()
    }

    // MARK: - Static Present Method

    static func present(
        on viewController: UIViewController,
        hobbyName: String,
        onGallerySelected: @escaping () -> Void,
        onActivitySelected: @escaping () -> Void
    ) {
        let sheet = CoverImageOptionSheet(
            hobbyName: hobbyName,
            onGallerySelected: onGallerySelected,
            onActivitySelected: onActivitySelected
        )
        viewController.present(sheet, animated: false)
    }
}

// MARK: - Setup

extension CoverImageOptionSheet {
    private func style() {
        view.backgroundColor = .clear

        dimmerView.do {
            $0.backgroundColor = .black.withAlphaComponent(0.5)
            $0.alpha = 0
        }

        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }
        titleLabel.setTextWithTypography("\(hobbyName) 대표사진 설정", style: .header18)

        optionsStackView.do {
            $0.axis = .vertical
            $0.spacing = 10
            $0.alignment = .fill
            $0.distribution = .fill
        }

        galleryOptionCard.do {
            $0.configure(title: "앨범에서 사진 선택")
        }

        activityOptionCard.do {
            $0.configure(title: "내 활동 중에서 사진 선택")
        }

        bottomButtonView.do {
            $0.backgroundColor = .clear
        }

        confirmButton.do {
            var config = UIButton.Configuration.filled()
            config.baseForegroundColor = .neutralWhite
            config.baseBackgroundColor = .action001
            config.cornerStyle = .fixed
            config.background.cornerRadius = 12
            config.attributedTitle = AttributedString(
                "설정완료",
                attributes: AttributeContainer([.font: TypographyStyle.header16.font])
            )
            $0.configuration = config
        }
    }

    private func layout() {
        view.addSubview(dimmerView)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(optionsStackView)
        optionsStackView.addArrangedSubview(galleryOptionCard)
        optionsStackView.addArrangedSubview(activityOptionCard)
        containerView.addSubview(bottomButtonView)
        bottomButtonView.addSubview(bottomGradientView)
        bottomButtonView.addSubview(confirmButton)

        dimmerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(20)
        }

        optionsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        galleryOptionCard.snp.makeConstraints {
            $0.height.equalTo(54)
        }

        activityOptionCard.snp.makeConstraints {
            $0.height.equalTo(54)
        }

        bottomButtonView.snp.makeConstraints {
            $0.top.equalTo(optionsStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(88)
        }

        bottomGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        confirmButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(56)
        }

        // Initial position for animation (off-screen)
        containerView.transform = CGAffineTransform(translationX: 0, y: 400)
    }

    private func setupActions() {
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dismissSheet))
        dimmerView.addGestureRecognizer(dimmerTap)

        let galleryTap = UITapGestureRecognizer(target: self, action: #selector(galleryOptionTapped))
        galleryOptionCard.addGestureRecognizer(galleryTap)

        let activityTap = UITapGestureRecognizer(target: self, action: #selector(activityOptionTapped))
        activityOptionCard.addGestureRecognizer(activityTap)

        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

extension CoverImageOptionSheet {
    @objc private func dismissSheet() {
        animateDismissal()
    }

    @objc private func galleryOptionTapped() {
        selectedOption = .gallery
        galleryOptionCard.setSelected(true)
        activityOptionCard.setSelected(false)
    }

    @objc private func activityOptionTapped() {
        selectedOption = .activity
        galleryOptionCard.setSelected(false)
        activityOptionCard.setSelected(true)
    }

    @objc private func confirmButtonTapped() {
        guard let option = selectedOption else {
            // 선택하지 않은 경우 토스트 등으로 알림
            return
        }

        animateDismissal { [weak self] in
            switch option {
            case .gallery:
                self?.onGallerySelected()
            case .activity:
                self?.onActivitySelected()
            }
        }
    }

    private func animatePresentation() {
        UIView.animate(withDuration: 0.3) {
            self.dimmerView.alpha = 1
            self.containerView.transform = .identity
        }
    }

    private func animateDismissal(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmerView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 400)
        }, completion: { _ in
            self.dismiss(animated: false) {
                completion?()
            }
        })
    }
}

// MARK: - OptionCardView

private final class OptionCardView: UIView {

    // MARK: - UI Components

    private let titleLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(title: String) {
        titleLabel.setTextWithTypography(title, style: .body14)
    }

    func setSelected(_ selected: Bool) {
        layer.borderColor = selected ? UIColor.action001.cgColor : UIColor.stroke001.cgColor
        layer.borderWidth = selected ? 2 : 1
    }
}

// MARK: - OptionCardView Setup

extension OptionCardView {
    private func style() {
        backgroundColor = .neutralWhite
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.stroke001.cgColor

        titleLabel.do {
            $0.textColor = .neutral800
        }
    }

    private func layout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
