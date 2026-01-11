//
//  GradientProgressView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class GradientProgressView: UIView {
    
    // Properties
    
    private let trackView = UIView()
    private let progressView = UIView()
    private var progressGradientLayer: CAGradientLayer?
    
    private var progressWidthConstraint: Constraint?
    
    var progress: Float = 0 {
        didSet {
            updateProgress()
        }
    }
    
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

extension GradientProgressView {
    private func style() {
        // Track (배경)
        trackView.do {
            $0.backgroundColor = .systemGray5
            $0.layer.cornerRadius = 4
        }
        
        // Progress (그라디언트)
        progressView.do {
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
        }
        
        // 그라디언트 적용
        progressGradientLayer = UIView.gradient001()
        if let gradient = progressGradientLayer {
            progressView.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    private func layout() {
        addSubview(trackView)
        addSubview(progressView)
        
        trackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        progressView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthConstraint = $0.width.equalToSuperview().multipliedBy(0).constraint
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 그라디언트 frame 업데이트
        progressGradientLayer?.frame = progressView.bounds
    }
}

// Public Methods

extension GradientProgressView {
    /// Progress 설정 (애니메이션 포함)
    func setProgress(_ progress: Float, animated: Bool = true) {
        self.progress = max(0, min(progress, 1))
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.updateProgressConstraint()
                self.layoutIfNeeded()
            }
        } else {
            updateProgressConstraint()
        }
    }
    
    private func updateProgressConstraint() {
        progressWidthConstraint?.update(offset: bounds.width * CGFloat(progress))
    }
    
    private func updateProgress() {
        updateProgressConstraint()
        layoutIfNeeded()
    }
}