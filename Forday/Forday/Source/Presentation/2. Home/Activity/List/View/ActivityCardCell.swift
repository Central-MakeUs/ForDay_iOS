//
//  ActivityCardCell.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import SnapKit
import Then

class ActivityCardCell: UITableViewCell {
    
    static let identifier = "ActivityCardCell"
    
    // Properties
    
    private let containerView = UIView()
    private let contentLabel = UILabel()
    private let aiRecommendedLabel = UILabel()
    private let editButton = UIButton()
    private let deleteButton = UIButton()
    private let stickerCollectionView: UICollectionView
    
    private var stickers: [ActivitySticker] = []
    
    // Callbacks
    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    // Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // CollectionView Layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.minimumLineSpacing = 8
        
        stickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension ActivityCardCell {
    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.do {
            $0.backgroundColor = .systemBackground
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray5.cgColor
        }
        
        contentLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        aiRecommendedLabel.do {
            $0.text = "AI 추천 루틴"
            $0.font = .systemFont(ofSize: 12, weight: .bold)
            $0.textColor = .systemOrange
            $0.isHidden = true
        }
        
        editButton.do {
            $0.setImage(UIImage(systemName: "pencil"), for: .normal)
            $0.tintColor = .systemGray
        }
        
        deleteButton.do {
            $0.setImage(UIImage(systemName: "trash"), for: .normal)
            $0.tintColor = .systemGray
        }
        
        stickerCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.register(StickerItemCell.self, forCellWithReuseIdentifier: StickerItemCell.identifier)
            $0.delegate = self
            $0.dataSource = self
            $0.isHidden = true
        }
    }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(contentLabel)
        containerView.addSubview(aiRecommendedLabel)
        containerView.addSubview(editButton)
        containerView.addSubview(deleteButton)
        containerView.addSubview(stickerCollectionView)
        
        // Container
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        // Content Label
        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(editButton.snp.leading).offset(-8)
        }
        
        // AI Recommended Label
        aiRecommendedLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
            $0.leading.equalTo(contentLabel)
        }
        
        // Edit Button
        editButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            $0.width.height.equalTo(24)
        }
        
        // Delete Button
        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        
        // Sticker CollectionView
        stickerCollectionView.snp.makeConstraints {
            $0.top.equalTo(aiRecommendedLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func editButtonTapped() {
        onEditTapped?()
    }
    
    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
}

// Configure

extension ActivityCardCell {
    func configure(with activity: Activity) {
        contentLabel.text = activity.content
        aiRecommendedLabel.isHidden = !activity.aiRecommended
        deleteButton.isHidden = !activity.deletable
        
        stickers = activity.stickers
        stickerCollectionView.isHidden = stickers.isEmpty
        stickerCollectionView.reloadData()
        
        // 레이아웃 업데이트
        if stickers.isEmpty {
            containerView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(8)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview().offset(-8)
            }
            
            aiRecommendedLabel.snp.remakeConstraints {
                $0.top.equalTo(contentLabel.snp.bottom).offset(8)
                $0.leading.equalTo(contentLabel)
                $0.bottom.equalToSuperview().offset(-16)
            }
        } else {
            containerView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(8)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview().offset(-8)
            }
            
            stickerCollectionView.snp.remakeConstraints {
                $0.top.equalTo(aiRecommendedLabel.isHidden ? contentLabel.snp.bottom : aiRecommendedLabel.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(60)
                $0.bottom.equalToSuperview().offset(-16)
            }
        }
    }
}

// UICollectionViewDataSource

extension ActivityCardCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerItemCell.identifier, for: indexPath) as? StickerItemCell else {
            return UICollectionViewCell()
        }
        
        let sticker = stickers[indexPath.item]
        cell.configure(with: sticker)
        
        return cell
    }
}

// UICollectionViewDelegateFlowLayout

extension ActivityCardCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}