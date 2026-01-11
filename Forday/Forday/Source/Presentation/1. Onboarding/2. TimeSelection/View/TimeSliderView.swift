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
    private let timeOptionsStackView = UIStackView()
    private var timeLabels: [UILabel] = []
    
    private let thumbView = UIView()
    private let thumbLabel = UILabel()
    
    // Constraint 저장용
    private var thumbCenterXConstraint: Constraint?
    
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
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
        }
        
        rightLabel.do {
            $0.text = "더 몰입"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
        }
        
        // Track
        trackView.do {
            $0.backgroundColor = .primary003
            $0.layer.cornerRadius = 20
        }
        
        // Time Options StackView
        timeOptionsStackView.do {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
        }
        
        // Time Labels
        for time in timeOptions {
            let label = UILabel()
            label.do {
                $0.text = formattedTime(minutes: time)
                $0.font = .systemFont(ofSize: 16, weight: .medium)
                $0.textColor = .secondaryLabel
                $0.textAlignment = .center
                $0.setContentHuggingPriority(.required, for: .horizontal)
                $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            }
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
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textColor = .white
            $0.textAlignment = .center
        }
    }
    
    private func layout() {
        addSubview(descriptionStackView)
        addSubview(trackView)
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
        
        // Time Options
        timeOptionsStackView.snp.makeConstraints {
            $0.centerY.equalTo(trackView.snp.centerY)
            $0.leading.trailing.equalToSuperview()
        }
        
        // Thumb (centerX 사용!)
        thumbView.snp.makeConstraints {
            $0.centerY.equalTo(trackView)
            // TODO: thumbview 위치 조정
            thumbCenterXConstraint = $0.centerX.equalTo(trackView.snp.leading).offset(20).constraint
        }
        
        // Thumb Label
        thumbLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
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
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: trackView)
        
        switch gesture.state {
        case .changed:
            moveThumb(to: location.x)
            
        case .ended:
            snapToNearestOption()
            
        default:
            break
        }
    }
    
    private func moveThumb(to x: CGFloat) {
        let trackWidth = trackView.bounds.width
        let clampedX = max(0, min(x, trackWidth))
        
        // 현재 위치에서 가장 가까운 인덱스 계산
        let optionSpacing = trackWidth / CGFloat(timeOptions.count - 1)
        let currentIndex = Int(round(clampedX / optionSpacing))
        let clampedIndex = max(0, min(currentIndex, timeOptions.count - 1))
        
        // 인덱스가 바뀌면 업데이트
        if selectedIndex != clampedIndex {
            selectedIndex = clampedIndex
        }
        
        // Constraint 업데이트
        thumbCenterXConstraint?.update(offset: clampedX)
    }
    
    private func snapToNearestOption() {
        let trackWidth = trackView.bounds.width
        let thumbCenterX = thumbView.center.x - trackView.frame.minX
        
        // 각 옵션의 위치 계산
        let optionSpacing = trackWidth / CGFloat(timeOptions.count - 1)
        
        // 가장 가까운 인덱스
        let closestIndex = Int(round(thumbCenterX / optionSpacing))
        let clampedIndex = max(0, min(closestIndex, timeOptions.count - 1))
        
        selectedIndex = clampedIndex
        
        // 스냅 애니메이션
        let targetX = optionSpacing * CGFloat(selectedIndex)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.thumbCenterXConstraint?.update(offset: targetX)
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
    }
}

#Preview {
    TimeSliderView()
}
