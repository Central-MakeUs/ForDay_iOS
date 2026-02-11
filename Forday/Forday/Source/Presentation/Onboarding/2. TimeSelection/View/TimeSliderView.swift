//
//  TimeSliderView.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit
import SnapKit
import Then

class TimeSliderView: UIView {
    
    // Properties
    // 시간을 분 단위로 저장
    let timeOptions = [10, 20, 30, 60, 120]
    
    private func formattedTime(minutes: Int) ->String {
        if minutes < 60 {
            return "\(minutes)분"
        } else {
            return "\(minutes / 60)시간"
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    // Callback
    var onValueChanged: ((String) -> Void)?
    
    // UI Components
    
    private let descriptionStackView = UIStackView()
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()
    
    private let trackView = UIView()
    private let progressView = UIView()
    private let timeOptionsStackView = UIStackView()
    private var timeLabels: [UILabel] = []

    private let thumbView = UIView()
    private let thumbLabel = UILabel()

    // Constraint 저장용
    private var thumbCenterXConstraint: Constraint?
    private var progressWidthConstraint: Constraint?
    private var isPanning = false
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupGesture()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !isPanning {
            updatePositions()
        }
    }

    // Helpers

    private func segmentWidth() -> CGFloat {
        return trackView.bounds.width / CGFloat(timeOptions.count)
    }

    private func thumbCenterXOffset(for index: Int) -> CGFloat {
        let sw = segmentWidth()
        return sw * CGFloat(index) + sw / 2
    }

    private func updatePositions() {
        let target = thumbCenterXOffset(for: selectedIndex)
        thumbCenterXConstraint?.update(offset: target)
        progressWidthConstraint?.update(offset: target)
    }
}

// Setup

extension TimeSliderView {
    private func style() {
        // Description StackView
        descriptionStackView.do {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
        }
        
        leftLabel.do {
            $0.text = "가벼운 시작"
            $0.applyTypography(.label12)
            $0.textColor = .neutral600
        }
        
        rightLabel.do {
            $0.text = "더 몰입"
            $0.applyTypography(.label12)
            $0.textColor = .neutral600
        }
        
        // Track
        trackView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        // Progress View
        progressView.do {
            $0.backgroundColor = .primary003
        }
        
        // Time Options StackView
        timeOptionsStackView.do {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .center
        }
        
        // Time Labels
        for time in timeOptions {
            let label = UILabel()
            label.do {
                $0.text = formattedTime(minutes: time)
                $0.font = .systemFont(ofSize: 14, weight: .medium)
                $0.textColor = .secondaryLabel
                $0.textAlignment = .center
                $0.isUserInteractionEnabled = true
            }

            // Add tap gesture to each label
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap))
            label.addGestureRecognizer(tapGesture)

            timeLabels.append(label)
            timeOptionsStackView.addArrangedSubview(label)
        }
        
        // Thumb
        thumbView.do {
            $0.backgroundColor = .primary001
            $0.layer.cornerRadius = 20
        }
        
        thumbLabel.do {
            $0.text = formattedTime(minutes: timeOptions[0])
            $0.applyTypography(.body14)
            $0.textColor = .neutral50
            $0.textAlignment = .center
        }
    }
    
    private func layout() {
        addSubview(descriptionStackView)
        addSubview(trackView)
        trackView.addSubview(progressView)
        trackView.addSubview(timeOptionsStackView)
        addSubview(thumbView)
        thumbView.addSubview(thumbLabel)
        
        descriptionStackView.addArrangedSubview(leftLabel)
        descriptionStackView.addArrangedSubview(rightLabel)
        
        // Description
        descriptionStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        // Track
        trackView.snp.makeConstraints {
            $0.top.equalTo(descriptionStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(descriptionStackView)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview()
        }

        // Progress View
        progressView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthConstraint = $0.width.equalTo(0).constraint
        }

        // Time Options
        timeOptionsStackView.snp.makeConstraints {
            $0.centerY.equalTo(trackView.snp.centerY)
            $0.leading.trailing.equalToSuperview()
        }
        
        // Thumb (centerX 사용!)
        thumbView.snp.makeConstraints {
            $0.centerY.equalTo(trackView)
            $0.height.equalTo(40)
            thumbCenterXConstraint = $0.centerX.equalTo(trackView.snp.leading).constraint
        }

        // Thumb Label
        thumbLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalToSuperview().offset(-17)
        }
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        thumbView.addGestureRecognizer(panGesture)
    }
}

// Gesture Handling

extension TimeSliderView {
    @objc private func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel,
              let index = timeLabels.firstIndex(of: tappedLabel) else { return }

        selectedIndex = index

        // Snap animation
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }

        // Callback
        onValueChanged?(formattedTime(minutes: timeOptions[selectedIndex]))
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: trackView)

        switch gesture.state {
        case .began:
            isPanning = true
        case .changed:
            moveThumb(to: location.x)
        case .ended, .cancelled:
            isPanning = false
            snapToNearestOption()
        default:
            break
        }
    }
    
    private func moveThumb(to x: CGFloat) {
        let trackWidth = trackView.bounds.width
        let clampedX = max(0, min(x, trackWidth))

        // 현재 위치에서 가장 가까운 인덱스 계산 (segment 기반)
        let segWidth = segmentWidth()
        guard segWidth > 0 else { return }
        let currentIndex = max(0, min(Int(clampedX / segWidth), timeOptions.count - 1))

        // 인덱스가 바뀌면 업데이트 (label 색상, thumb 텍스트)
        if selectedIndex != currentIndex {
            selectedIndex = currentIndex
        }

        // Constraint 업데이트 (thumb은 손가락 따라감)
        thumbCenterXConstraint?.update(offset: clampedX)
        progressWidthConstraint?.update(offset: clampedX)
    }
    
    private func snapToNearestOption() {
        let segWidth = segmentWidth()
        guard segWidth > 0 else { return }

        let thumbCenterX = thumbView.center.x - trackView.frame.minX

        // 가장 가까운 segment 인덱스
        let closestIndex = max(0, min(Int(thumbCenterX / segWidth), timeOptions.count - 1))
        selectedIndex = closestIndex

        // 스냅 애니메이션 (segment 중앙으로)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }

        // Callback
        onValueChanged?(formattedTime(minutes: timeOptions[selectedIndex]))
    }
    
    private func updateUI() {
        // 라벨 색상 업데이트
        for (index, label) in timeLabels.enumerated() {
            label.textColor = index == selectedIndex ? .systemOrange : .secondaryLabel
        }

        // Thumb 라벨 업데이트
        thumbLabel.text = formattedTime(minutes: timeOptions[selectedIndex])

        // Thumb, Progress 위치 업데이트
        updatePositions()
    }
}

#Preview {
    TimeSliderView()
}
