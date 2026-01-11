//
//  PurposeSelectionView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class PurposeSelectionView: UIView {
    
    // Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    let customInputButton = UIButton(type: .system)
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        
        // 임시 데이터
        selectedHobbyCard.configure(
            iconName: "book.fill",
            time: "30분",
            title: "독서"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension PurposeSelectionView {
    private func style() {
        backgroundColor = .systemBackground
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }
        
        titleLabel.do {
            $0.text = "어떤 목적으로 시작하나요?"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "독서를 통해 얻고 싶은 것을 선택해주세요.\n목적이 명확하면 동기부여가 더 쉬워져요!"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
            
            // "독서" 텍스트 색상 변경
            let fullText = $0.text ?? ""
            let attributedString = NSMutableAttributedString(string: fullText)
            if let range = fullText.range(of: "독서") {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: nsRange)
            }
            $0.attributedText = attributedString
        }
        
        collectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false  // 외부 ScrollView 사용
            $0.register(PurposeOptionCell.self, forCellWithReuseIdentifier: PurposeOptionCell.identifier)
        }
        
        customInputButton.do {
            $0.setTitle("✏️  원하는 목적이 없으신가요?", for: .normal)
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
        contentView.addSubview(selectedHobbyCard)
        contentView.addSubview(collectionView)
        contentView.addSubview(customInputButton)
        
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
        
        // Selected Hobby Card
        selectedHobbyCard.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // CollectionView
        collectionView.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(400)  // 임시 높이 (2x2 그리드)
        }
        
        // Custom Input Button
        customInputButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
}
