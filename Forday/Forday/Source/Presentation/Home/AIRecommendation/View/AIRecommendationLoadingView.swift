//
//  AIRecommendationLoadingView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then
import Lottie

class AIRecommendationLoadingView: UIView {

    // MARK: - Properties

    private let containerView = UIView()

    // Lottie 로딩 애니메이션
    private let lottieView: LottieAnimationView = {
        // xcassets의 data set에서 Lottie JSON 로드
        if let dataAsset = NSDataAsset(name: "lottie/loading"),
           let animation = try? LottieAnimation.from(data: dataAsset.data) {
            return LottieAnimationView(animation: animation)
        }
        return LottieAnimationView()
    }()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // 하단 토스트
    private let toastView = UIView()
    private let toastLabel = UILabel()

    // 토스트 텍스트 애니메이션
    private let toastMessages = [
        "당신의 취향과 패턴을 분석했어요",
        "AI가 꼭 맞는 활동을 찾아줄게요",
        "활동은 추가로 받을 수 있어요"
    ]
    private var currentMessageIndex = 0
    private var toastTimer: Timer?

    /// 하단 토스트 표시 여부 (fullscreen 모드에서만 true)
    private var showToast: Bool = true

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        startAnimations()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopAnimations()
    }

    private func stopAnimations() {
        lottieView.stop()
        stopToastAnimation()
    }
}

// MARK: - Setup

extension AIRecommendationLoadingView {
    private func style() {
        backgroundColor = .neutralWhite

        // Lottie
        lottieView.do {
            $0.loopMode = .loop
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        subtitleLabel.do {
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        // Toast
        toastView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            $0.layer.cornerRadius = 16
        }

        toastLabel.do {
            $0.textColor = .white
            $0.textAlignment = .center
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(lottieView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        addSubview(toastView)
        toastView.addSubview(toastLabel)

        // Container - 화면 정중앙
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Lottie
        lottieView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        }

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(lottieView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        // Toast - 하단
        toastView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }

        toastLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }

    private func startAnimations() {
        startLottieAnimation()
        // Toast animation은 configure에서 showToast가 true일 때만 시작
    }

    private func startLottieAnimation() {
        lottieView.play()
    }

    private func startToastAnimation() {
        // 첫 번째 메시지 표시
        updateToastMessage(animated: false)

        // 2초마다 텍스트 변경
        toastTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.showNextToastMessage()
        }
    }

    private func stopToastAnimation() {
        toastTimer?.invalidate()
        toastTimer = nil
    }

    private func showNextToastMessage() {
        currentMessageIndex = (currentMessageIndex + 1) % toastMessages.count
        updateToastMessage(animated: true)
    }

    private func updateToastMessage(animated: Bool) {
        let message = toastMessages[currentMessageIndex]

        if animated {
            // 페이드 아웃 -> 텍스트 변경 -> 페이드 인
            UIView.animate(withDuration: 0.3, animations: {
                self.toastLabel.alpha = 0
            }) { _ in
                self.toastLabel.setTextWithTypography(message, style: .body14)
                UIView.animate(withDuration: 0.3) {
                    self.toastLabel.alpha = 1
                }
            }
        } else {
            toastLabel.setTextWithTypography(message, style: .body14)
        }
    }
}

// MARK: - Public Methods

extension AIRecommendationLoadingView {
    /// 로딩 뷰 설정
    /// - Parameters:
    ///   - nickname: 사용자 닉네임
    ///   - hobbyName: 취미 이름
    ///   - showToast: 하단 토스트 표시 여부 (fullscreen 모드에서만 true)
    func configure(nickname: String, hobbyName: String, showToast: Bool = true) {
        self.showToast = showToast

        // 타이틀, 서브타이틀은 항상 표시
        titleLabel.setTextWithTypography("\(nickname)의 취미를 분석 중", style: .header20)
        subtitleLabel.setTextWithTypography("\(hobbyName) AI 활동을 생성 중이에요.", style: .label14)

        if showToast {
            // Fullscreen 모드: 토스트 표시
            toastView.isHidden = false
            startToastAnimation()
        } else {
            // Sheet 모드: 토스트만 숨김
            toastView.isHidden = true
            stopToastAnimation()
        }
    }
}

#Preview("Fullscreen Mode") {
    let view = AIRecommendationLoadingView()
    view.configure(nickname: "유지2", hobbyName: "독서", showToast: true)
    return view
}

#Preview("Sheet Mode (Minimal)") {
    let view = AIRecommendationLoadingView()
    view.configure(nickname: "유지2", hobbyName: "독서", showToast: false)
    return view
}
