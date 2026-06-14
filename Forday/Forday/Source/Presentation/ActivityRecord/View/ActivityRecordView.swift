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

    // 취미 칩 선택
    let hobbyChipCollectionView: UICollectionView

    // 수정 모드 전용: 단일 취미 칩
    private let singleHobbyChipContainer = UIView()
    let singleHobbyChipView = UIView()
    private let singleHobbyChipLabel = UILabel()

    // 활동명 입력
    private let activityNameLabel = UILabel()
    let previousActivityButton = UIButton()
    private let activityNameContainerView = UIView()
    let activityNameTextField = UITextField()
    private let activityNameCountLabel = UILabel()

    // 스티커 선택
    private let stickerLabel = UILabel()
    let stickerCollectionView: UICollectionView
    
    // 취미 사진 (메모 위에 위치)
    private let photoLabel = UILabel()
    let photoCollectionView: UICollectionView

    // 한 줄 메모
    private let memoLabel = UILabel()
    private let memoContainerView = UIView()
    let memoTextView = UITextView()
    private let memoPlaceholderLabel = UILabel()
    private let memoCountLabel = UILabel()

    // 메모 추천 문장 뷰 (키보드 위에 표시)
    let memoSuggestionView = MemoSuggestionView()
    
    // 기록 공개범위
    private let privacyLabel = UILabel()
    let privacyButton = UIButton()
    private let privacyDescriptionLabel = UILabel()
    
    // 작성완료 버튼
    let submitButton = UIButton()
    
    // MARK: - CollectionView Height Constraint

    private var hobbyChipHeightConstraint: Constraint?

    // Initialization

    override init(frame: CGRect) {
        // Hobby Chip CollectionView Layout (wrap layout using CompositionalLayout)
        let hobbyChipLayout = ActivityRecordView.createHobbyChipLayout()
        hobbyChipCollectionView = UICollectionView(frame: .zero, collectionViewLayout: hobbyChipLayout)

        // Sticker CollectionView Layout
        let stickerLayout = UICollectionViewFlowLayout()
        stickerLayout.scrollDirection = .horizontal
        stickerLayout.minimumInteritemSpacing = 12
        stickerLayout.minimumLineSpacing = 12

        stickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: stickerLayout)

        // Photo CollectionView Layout
        let photoLayout = UICollectionViewFlowLayout()
        photoLayout.scrollDirection = .horizontal
        photoLayout.minimumInteritemSpacing = 8
        photoLayout.minimumLineSpacing = 8
        photoLayout.itemSize = CGSize(width: 56, height: 56)  // 52 + 삭제 버튼 여백

        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: photoLayout)

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

        // 취미 칩 선택 (wrap layout)
        hobbyChipCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false  // wrap 레이아웃이므로 스크롤 비활성화
            $0.register(HobbyChipCell.self, forCellWithReuseIdentifier: "HobbyChipCell")
            $0.register(HobbyAddChipCell.self, forCellWithReuseIdentifier: "HobbyAddChipCell")
        }

        // 수정 모드 전용: 단일 취미 칩
        singleHobbyChipContainer.do {
            $0.backgroundColor = .clear
            $0.isHidden = true  // 기본적으로 숨김 (생성 모드)
        }

        singleHobbyChipView.do {
            $0.backgroundColor = .action001
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.action001.cgColor
            $0.clipsToBounds = true
        }

        singleHobbyChipLabel.do {
            $0.setTextWithTypography("", style: .body14)
            $0.textColor = .neutralWhite
            $0.textAlignment = .center
            $0.numberOfLines = 1
        }

        // 활동명 입력
        activityNameLabel.do {
            $0.setTextWithTypography("*활동명", style: .body14)
            $0.textColor = .neutral800
        }

        previousActivityButton.do {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = AttributedString(
                "이전 활동리스트",
                attributes: AttributeContainer(TypographyStyle.body12.attributes)
            )
            config.contentInsets = .zero
            config.baseForegroundColor = .action001

            $0.configuration = config
        }

        activityNameContainerView.do {
            $0.backgroundColor = .neutral50
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }

        activityNameTextField.do {
            $0.font = TypographyStyle.body14.font
            $0.textColor = .neutral800
            $0.backgroundColor = .clear
            $0.placeholder = "활동명을 입력해주세요"
            $0.attributedPlaceholder = NSAttributedString(
                string: "활동명을 입력해주세요",
                attributes: [
                    .font: TypographyStyle.body14.font,
                    .foregroundColor: UIColor.neutral400
                ]
            )
        }

        activityNameCountLabel.do {
            $0.setTextWithTypography("0/20", style: .label10)
            $0.textColor = .neutral400
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

        // 취미 사진
        photoLabel.do {
            $0.setTextWithTypography("*취미 사진", style: .body14)
            $0.textColor = .neutral800
        }

        photoCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.clipsToBounds = false
            $0.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
            $0.register(PhotoAddCell.self, forCellWithReuseIdentifier: "PhotoAddCell")
        }

        // 한 줄 메모 (선택)
        memoLabel.do {
            $0.setTextWithTypography("취미 메모", style: .body14)
            $0.textColor = .neutral800
        }

        memoContainerView.do {
            $0.backgroundColor = .neutral50
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = false
        }

        memoTextView.do {
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral800
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0
        }

        // 메모 추천 문장 뷰 (키보드 위에 표시)
        memoSuggestionView.do {
            $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: MemoSuggestionView.defaultHeight)
        }
        memoTextView.inputAccessoryView = memoSuggestionView

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
            config.attributedTitle = AttributedString(
                "전체공개",
                attributes: AttributeContainer(TypographyStyle.label14.attributes)
            )
            config.image = .Icon.chevronDown
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.contentInsets = .zero
            config.baseForegroundColor = .neutral600

            $0.configuration = config
            $0.contentHorizontalAlignment = .trailing
        }

        privacyDescriptionLabel.do {
            $0.setTextWithTypography("모든 사람이 이 기록을 볼 수 있습니다.", style: .label12)
            $0.textColor = .neutral500
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

        contentView.addSubview(hobbyChipCollectionView)
        contentView.addSubview(singleHobbyChipContainer)

        singleHobbyChipContainer.addSubview(singleHobbyChipView)
        singleHobbyChipView.addSubview(singleHobbyChipLabel)
        contentView.addSubview(activityNameLabel)
        contentView.addSubview(previousActivityButton)
        contentView.addSubview(activityNameContainerView)
        activityNameContainerView.addSubview(activityNameTextField)
        contentView.addSubview(activityNameCountLabel)
        contentView.addSubview(stickerLabel)
        contentView.addSubview(stickerCollectionView)
        contentView.addSubview(photoLabel)
        contentView.addSubview(photoCollectionView)
        contentView.addSubview(memoLabel)
        contentView.addSubview(memoContainerView)
        contentView.addSubview(privacyLabel)
        contentView.addSubview(privacyButton)
        contentView.addSubview(privacyDescriptionLabel)
        contentView.addSubview(submitButton)
        
        memoContainerView.addSubview(memoTextView)
        memoContainerView.addSubview(memoPlaceholderLabel)
        memoContainerView.addSubview(memoCountLabel)
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(layoutMarginsGuide)
        }

        // 취미 칩 (CollectionView) - wrap layout, 동적 높이
        // TODO: 기획자에게 최대 높이/줄 수 확인 필요
        hobbyChipCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            hobbyChipHeightConstraint = $0.height.equalTo(32).constraint  // 초기값, 동적으로 업데이트
        }

        // 단일 취미 칩 (수정 모드)
        singleHobbyChipContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(32)
        }

        singleHobbyChipView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }

        singleHobbyChipLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        // 활동명 입력
        activityNameLabel.snp.makeConstraints {
            $0.top.equalTo(hobbyChipCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        previousActivityButton.snp.makeConstraints {
            $0.centerY.equalTo(activityNameLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }

        activityNameContainerView.snp.makeConstraints {
            $0.top.equalTo(activityNameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }

        activityNameTextField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        activityNameCountLabel.snp.makeConstraints {
            $0.top.equalTo(activityNameContainerView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // 스티커
        stickerLabel.snp.makeConstraints {
            $0.top.equalTo(activityNameCountLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        stickerCollectionView.snp.makeConstraints {
            $0.top.equalTo(stickerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
        }

        // 취미 사진
        photoLabel.snp.makeConstraints {
            $0.top.equalTo(stickerCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        photoCollectionView.snp.makeConstraints {
            $0.top.equalTo(photoLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)  // 52 + 삭제 버튼 상단 여백
        }

        // 취미 메모
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(photoCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        memoContainerView.snp.makeConstraints {
            $0.top.equalTo(memoLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(120)  // Figma 스펙: 120px
        }

        memoTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(memoCountLabel.snp.top).offset(-8)
        }

        memoPlaceholderLabel.snp.makeConstraints {
            $0.top.leading.equalTo(memoTextView)
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

        privacyDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(privacyLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
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
    func setSubmitButtonEnabled(_ isEnabled: Bool) {
        submitButton.isEnabled = isEnabled

        var config = submitButton.configuration
        config?.baseBackgroundColor = isEnabled ? .action001 : .neutral300
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

    func updateActivityNameCount(_ count: Int) {
        activityNameCountLabel.setTextWithTypography("\(count)/20", style: .label10)
    }

    func updateMemoPlaceholder(isHidden: Bool) {
        memoPlaceholderLabel.isHidden = isHidden
    }

    func updatePrivacyDescription(_ privacy: Privacy) {
        let description: String
        switch privacy {
        case .public:
            description = "모든 사람이 이 기록을 볼 수 있습니다."
        case .friend:
            description = "나를 친구추가한 사람들에게만 이 기록을 공개합니다."
        case .private:
            description = "이 기록은 나만 볼 수 있습니다."
        }
        privacyDescriptionLabel.setTextWithTypography(description, style: .label12)
    }

    func updatePrivacyButtonTitle(_ title: String) {
        var config = privacyButton.configuration
        config?.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer(TypographyStyle.label14.attributes)
        )
        privacyButton.configuration = config
    }

    func showSingleHobbyChip(_ hobbyName: String, show: Bool) {
        singleHobbyChipContainer.isHidden = !show
        hobbyChipCollectionView.isHidden = show
        singleHobbyChipLabel.text = hobbyName
    }

    /// CollectionView 컨텐츠 크기에 맞게 높이 업데이트
    func updateHobbyChipCollectionViewHeight() {
        hobbyChipCollectionView.layoutIfNeeded()
        let contentHeight = hobbyChipCollectionView.collectionViewLayout.collectionViewContentSize.height
        hobbyChipHeightConstraint?.update(offset: max(32, contentHeight))
    }
}

// MARK: - Layout Factory

extension ActivityRecordView {
    /// 취미 칩 wrap 레이아웃 생성
    static func createHobbyChipLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(60),
            heightDimension: .absolute(32)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(32)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(6)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6

        return UICollectionViewCompositionalLayout(section: section)
    }
}

#Preview {
    ActivityRecordView()
}
