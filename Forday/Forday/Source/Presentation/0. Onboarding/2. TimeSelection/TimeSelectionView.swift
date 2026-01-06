//
//  TimeSelectionView.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit
import SnapKit
import Then

class TimeSelectionView: UIView {
    
    // Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let timeSlider = TimeSliderView()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension TimeSelectionView {
    private func style() {
        backgroundColor = .systemBackground
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }
        
        titleLabel.do {
            $0.text = "한 번에 얼마나 할 수 있나요?"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "독서에 투자할 수 있는 시간을 선택해주세요.\n💡 처음엔 짧게 시작하는 게 좋아요. 습관이 되면 자연스럽게 늘어나요!"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
        }
    }
    
    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(timeSlider)
        
        // ScrollView
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-80)
        }
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        // Time Slider
        timeSlider.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(80)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }
}
