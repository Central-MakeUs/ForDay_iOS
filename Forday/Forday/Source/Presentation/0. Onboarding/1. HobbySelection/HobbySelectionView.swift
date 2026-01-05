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
    
    // MARK: - Properties
    
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
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension HobbySelectionView {
    private func style() {
        backgroundColor = .systemBackground
        
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
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(collectionView)
        addSubview(customInputButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(customInputButton.snp.top).offset(-16)
        }
        
        customInputButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-80)
            $0.height.equalTo(44)
        }
    }
}