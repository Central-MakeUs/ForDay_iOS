//
//  HobbySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import UIKit
import SnapKit
import Then

class HobbySelectionView: UIView {
    
    // Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    let customInputButton = UIButton(type: .system)
    
    // CollectionView 높이 제약 (나중에 업데이트용)
    private var collectionViewHeightConstraint: Constraint?
    
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

extension HobbySelectionView {
    private func style() {
        backgroundColor = .systemBackground
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }
        
        titleLabel.do {
            $0.text = "어떤 취미를 시작하고 싶으세요?"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "마음에 드는 취미를 1개 선택해주세요.\n취미슬롯은 1개 더 확장 가능해요!"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
            
            // "1개" 텍스트 색상 변경
            let fullText = $0.text ?? ""
            let attributedString = NSMutableAttributedString(string: fullText)
            if let range = fullText.range(of: "1개") {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: nsRange)
            }
            $0.attributedText = attributedString
        }
        
        collectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = false  // CollectionView 스크롤 비활성화
            $0.register(HobbyCollectionViewCell.self, forCellWithReuseIdentifier: HobbyCollectionViewCell.identifier)
        }
        
        customInputButton.do {
            $0.setTitle("✏️  원하는 취미가 없으신가요?", for: .normal)
            $0.setTitleColor(.secondaryLabel, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            $0.contentHorizontalAlignment = .center
        }
    }
    
    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(customInputButton)
        
        // ScrollView
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-80)  // 다음 버튼 위까지
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
        
        // CollectionView
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            collectionViewHeightConstraint = $0.height.equalTo(0).constraint  // 초기값 0
        }
        
        // Custom Input Button
        customInputButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-24)  // ContentView 하단 (중요!)
        }
    }
}

// Public Methods

extension HobbySelectionView {
    /// CollectionView 높이 업데이트
    func updateCollectionViewHeight() {
        layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint?.update(offset: contentHeight)
        layoutIfNeeded()
    }
}
