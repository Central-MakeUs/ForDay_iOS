//
//  ActivityRecordView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

class ActivityRecordView: UIView {
    
    // Properties
    
//    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 활동 선택
    private let activityLabel = UILabel()
    let activityDropdownButton = UIButton()
    let addActivityButton = UIButton()  // 활동이 없을 때 표시
    
    // 스티커 선택
    private let stickerLabel = UILabel()
    let stickerCollectionView: UICollectionView
    
    // 한 줄 메모
    private let memoLabel = UILabel()
    private let memoContainerView = UIView()
    private let photoContainerView = UIView()
    let photoAddButton = UIButton()
    let photoDeleteButton = UIButton()
    let memoTextView = UITextView()
    private let memoPlaceholderLabel = UILabel()
    private let memoCountLabel = UILabel()
    
    // 기록 공개범위
    private let privacyLabel = UILabel()
    let privacyButton = UIButton()
    
    // 작성완료 버튼
    let submitButton = UIButton()
    
    // Initialization
    
    override init(frame: CGRect) {
        // CollectionView Layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.minimumLineSpacing = 12
        
        stickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension ActivityRecordView {
    private func style() {
        backgroundColor = .neutralWhite

        // 활동 (필수)
        activityLabel.do {
            $0.setTextWithTypography("활동 (필수)", style: .body14)
            $0.textColor = .neutral800
        }
        
        activityDropdownButton.do {
            var config = UIButton.Configuration.plain()
            config.title = "미라클 모닝 야침 독서"
            config.image = UIImage(systemName: "chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 8
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            config.background.backgroundColor = .systemGray6
            config.background.cornerRadius = 12
            config.baseForegroundColor = .label

            $0.configuration = config
            $0.contentHorizontalAlignment = .leading
        }

        addActivityButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary003
            config.baseForegroundColor = .action001
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 110, bottom: 12, trailing: 110)

            $0.configuration = config
            $0.setTitleWithTypography("취미활동 추가하기", style: .header14)
            $0.isHidden = true  // 기본적으로 숨김
        }
        
        // 스티커 선택 (필수)
        stickerLabel.do {
            $0.setTextWithTypography("스티커 선택 (필수)", style: .body14)
            $0.textColor = .neutral800
        }
        
        stickerCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.register(StickerCell.self, forCellWithReuseIdentifier: "StickerCell")
        }
        
        // 한 줄 메모 (선택)
        memoLabel.do {
            $0.setTextWithTypography("한 줄 메모 (선택)", style: .body14)
            $0.textColor = .neutral800
        }
        
        memoContainerView.do {
            $0.backgroundColor = .neutral50
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = false
        }

        photoContainerView.do {
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = false
        }

        photoAddButton.do {
            $0.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            $0.tintColor = .systemGray
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.imageView?.contentMode = .scaleAspectFill
        }

        photoDeleteButton.do {
            $0.setImage(.Icon.imageDelete, for: .normal)
            $0.isHidden = true
        }

        memoTextView.do {
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral800
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0
        }

        memoPlaceholderLabel.do {
            $0.text = "한 줄 메모를 입력해주세요"
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral400
        }

        memoCountLabel.do {
            $0.setTextWithTypography("0/100", style: .label10)
            $0.textColor = .neutral400
        }
        
        // 기록 공개범위
        privacyLabel.do {
            $0.setTextWithTypography("기록 공개범위", style: .body14)
            $0.textColor = .neutral800
        }
        
        privacyButton.do {
            var config = UIButton.Configuration.plain()
            config.title = "전체공개"
            config.image = UIImage(systemName: "chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 8
            config.baseForegroundColor = .label
            
            $0.configuration = config
            $0.contentHorizontalAlignment = .trailing
        }
        
        // 작성완료 버튼
        submitButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "작성완료"
            config.baseBackgroundColor = .action001
            config.baseForegroundColor = .neutralWhite
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 0, bottom: 19, trailing: 0)
            
            $0.configuration = config
            $0.isEnabled = false
        }
    }
    
    private func layout() {
        addSubview(contentView)
        
        contentView.addSubview(activityLabel)
        contentView.addSubview(activityDropdownButton)
        contentView.addSubview(addActivityButton)
        contentView.addSubview(stickerLabel)
        contentView.addSubview(stickerCollectionView)
        contentView.addSubview(memoLabel)
        contentView.addSubview(memoContainerView)
        contentView.addSubview(privacyLabel)
        contentView.addSubview(privacyButton)
        contentView.addSubview(submitButton)
        
        memoContainerView.addSubview(memoTextView)
        memoContainerView.addSubview(memoPlaceholderLabel)
        memoContainerView.addSubview(photoContainerView)
        memoContainerView.addSubview(memoCountLabel)

        photoContainerView.addSubview(photoAddButton)
        photoContainerView.addSubview(photoDeleteButton)
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(layoutMarginsGuide)
        }
        
        // 활동
        activityLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        activityDropdownButton.snp.makeConstraints {
            $0.top.equalTo(activityLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        addActivityButton.snp.makeConstraints {
            $0.top.equalTo(activityLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }

        // 스티커
        stickerLabel.snp.makeConstraints {
            $0.top.equalTo(activityDropdownButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        stickerCollectionView.snp.makeConstraints {
            $0.top.equalTo(stickerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
        }
        
        // 한 줄 메모
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(stickerCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        memoContainerView.snp.makeConstraints {
            $0.top.equalTo(memoLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(168)
        }

        memoTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(photoContainerView.snp.top).offset(-8)
        }

        memoPlaceholderLabel.snp.makeConstraints {
            $0.top.leading.equalTo(memoTextView)
        }

        photoContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.height.equalTo(48)
        }

        photoAddButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        photoDeleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-4)
            $0.trailing.equalToSuperview().offset(4)
            $0.width.height.equalTo(16)
        }

        memoCountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        // 기록 공개범위
        privacyLabel.snp.makeConstraints {
            $0.top.equalTo(memoContainerView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        privacyButton.snp.makeConstraints {
            $0.centerY.equalTo(privacyLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        // 작성완료 버튼
        submitButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

// Public Methods

extension ActivityRecordView {
    func updateActivityTitle(_ title: String?) {
        var config = activityDropdownButton.configuration
        config?.title = title ?? "활동을 선택해주세요"
        activityDropdownButton.configuration = config
    }

    func showAddActivityButton(_ show: Bool) {
        addActivityButton.isHidden = !show
        activityDropdownButton.isHidden = show
    }
    
    func setSubmitButtonEnabled(_ isEnabled: Bool) {
        submitButton.isEnabled = isEnabled

        var config = submitButton.configuration
        config?.baseBackgroundColor = isEnabled ? .action001 : .systemGray4
        submitButton.configuration = config
    }

    func setSubmitButtonTitle(_ title: String) {
        var config = submitButton.configuration
        config?.title = title
        submitButton.configuration = config
    }

    func updateMemoCount(_ count: Int) {
        memoCountLabel.setTextWithTypography("\(count)/100", style: .label10)
    }

    func updateMemoPlaceholder(isHidden: Bool) {
        memoPlaceholderLabel.isHidden = isHidden
    }

    func showPhotoDeleteButton(_ show: Bool) {
        photoDeleteButton.isHidden = !show
    }

    func updatePhotoImage(_ image: UIImage?) {
        if let image = image {
            photoAddButton.setImage(image, for: .normal)
            photoAddButton.imageView?.contentMode = .scaleAspectFill
            photoAddButton.tintColor = nil
            showPhotoDeleteButton(true)
        } else {
            photoAddButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            photoAddButton.tintColor = .systemGray
            showPhotoDeleteButton(false)
        }
    }
}

#Preview {
    ActivityRecordView()
}
