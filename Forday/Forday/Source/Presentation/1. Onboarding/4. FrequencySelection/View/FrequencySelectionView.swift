//
//  FrequencySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class FrequencySelectionView: UIView {
    
    // Properties
    
//    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let recommendLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        
        // 임시 데이터
        selectedHobbyCard.configure(
            iconName: "book.fill",
            time: "30분 · 주 2회",
            title: "독서"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension FrequencySelectionView {
    private func style() {
        backgroundColor = .systemBackground

        titleLabel.do {
            $0.text = "주 몇 회 하실 거예요?"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "독서를 일주일에 몇 번 할까요?\n(처음에는 작게 시작해도 좋아요! 언제든지 변경 가능해요.)"
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
        
        recommendLabel.do {
            $0.text = "추천"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .systemOrange
            $0.textAlignment = .center
        }
        
        collectionView.do {
            $0.backgroundColor = .clear
//            $0.showsHorizontalScrollIndicator = false
            $0.register(FrequencyButtonCell.self, forCellWithReuseIdentifier: FrequencyButtonCell.identifier)
        }
    }
    
    private func layout() {
        addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectedHobbyCard)
        contentView.addSubview(recommendLabel)
        contentView.addSubview(collectionView)

        // ContentView
        contentView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        // Selected Hobby Card
        selectedHobbyCard.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
        
        // Recommend Label
        recommendLabel.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        
        // CollectionView
        collectionView.snp.makeConstraints {
            $0.top.equalTo(recommendLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}

#Preview {
    FrequencySelectionView()
}
