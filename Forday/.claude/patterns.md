# Development Patterns

ForDay iOS 앱의 개발 패턴 및 코딩 규칙 가이드입니다.

## File Header Convention

When creating new files, always use the following header format:
```swift
//
//  FileName.swift
//  Forday
//
//  Created by Subeen on M/D/YY.
//
```

**Important**: Use "Created by Subeen" for all new files, not "Created by Claude".

## Repository Organization Rules

**CRITICAL**: Repositories are organized by **feature context**, NOT by API path.

### Separation Criteria

Separate repositories based on **which feature/screen uses the data**:

- **UsersRepository**: User account management (onboarding, profile setup)
  - `checkNicknameAvailability` - Used in onboarding & profile edit
  - `setNickname` - Used in onboarding & profile edit
  - `fetchHobbyCards` - Completed hobby cards (66 stickers)

- **MyPageRepository**: MyPage screen data aggregation
  - `fetchMyActivities` - Activity list for MyPage
  - `fetchMyHobbies` - Hobby list for MyPage
  - `fetchActivityDetail` - Activity detail view

### Multiple Service Usage

Repositories can use **multiple services** to aggregate data for a feature:

```swift
final class MyPageRepository: MyPageRepositoryInterface {
    private let usersService: UsersService
    private let recordsService: RecordsService

    func fetchActivityDetail(activityRecordId: Int) async throws -> ActivityDetail {
        let response = try await recordsService.fetchRecordDetail(recordId: activityRecordId)
        return response.toDomain()
    }
}
```

## Entity Naming Conventions

**CRITICAL**: Follow these naming rules for Domain entities:

| Pattern | Usage | Example |
|---------|-------|---------|
| `{Concept}` | Core domain object | `Activity`, `Hobby`, `UserProfile` |
| `{Screen}{Concept}` | Screen-specific data | `MyPageActivity`, `HomeInfo` |
| `{Concept}Result` | Paginated response | `MyActivitiesResult`, `HobbyCardsResult` |
| `{Action}Result` | API operation response | `SetNicknameResult`, `UploadImageResult` |
| `{Status}{Concept}` | State/milestone entity | `CompletedHobbyCard`, `ArchivedActivity` |

### Directory Placement

```
Domain/Entity/
├── Activity/
│   ├── Activity.swift
│   └── ActivityRecord.swift
├── User/
│   ├── UserProfile.swift
│   ├── CompletedHobbyCard.swift
│   └── SetNicknameResult.swift
└── MyPage/
    ├── MyPageActivity.swift
    ├── MyActivitiesResult.swift
    └── UserInfo.swift
```

## DTO Naming Conventions

**CRITICAL**: All DTOs live inside the `DTO` namespace.

### DTO Namespace Structure

```swift
// DTO+Namespace.swift
enum DTO { }

// HobbyInfo.swift
extension DTO {
    struct HobbyInfo: Codable {
        let hobbyInfoId: Int
        let hobbyName: String
    }
}
```

### Naming Rules

| Rule | ❌ Wrong | ✅ Correct |
|------|---------|-----------|
| No redundant "DTO" suffix | `DTO.HobbyInfoDTO` | `DTO.HobbyInfo` |
| Response suffix | `DTO.HomeInfo` | `DTO.HomeInfoResponse` |
| Request suffix | `DTO.CreateHobby` | `DTO.CreateHobbyRequest` |

### Conversion Method

Always use `toDomain()` for DTO → Entity conversion:

```swift
extension DTO.HomeInfoResponse {
    func toDomain() -> HomeInfo {
        // Convert DTO to domain entity
    }
}
```

### DTO File Organization

```
Data/Network/DTO/
├── DTO+Namespace.swift
├── HobbyInfo.swift               # Shared DTOs
├── Request/
│   └── Hobby/
│       └── CreateHobbyRequest.swift
└── Response/
    ├── Hobby/
    │   └── HomeInfoResponse.swift
    └── BaseResponse.swift
```

## Adding a New API Endpoint

1. Define endpoint in `Data/Network/API/Endpoint/`
2. Create DTOs in `Data/Network/DTO/`
3. Add domain entity in `Domain/Entity/`
4. Create repository interface in `Domain/RepositoryInterface/`
5. Implement repository in `Data/Repository/`
6. Create use case in `Domain/UseCase/`
7. Wire up in ViewModel
8. **Write test code for the UseCase**

## Testing Requirements

**CRITICAL**: Test code is MANDATORY for all UseCases.

### Test File Structure

```
FordayTests/
├── Mock/
│   └── Mock{Repository}.swift
├── Fixture/
│   └── {Entity}+Fixture.swift
└── UseCase/
    └── {Feature}/
        └── {UseCase}Tests.swift
```

### Required Test Cases per UseCase

1. **Success case** - Happy path with valid data
2. **Empty/nil case** - Handle empty responses
3. **Network error case** - `AppError.network(.noInternet)`, `.timeout`
4. **Server error case** - `AppError.server(ServerError(...))`
5. **Parameterized tests** - If UseCase accepts parameters

### Example Test Structure

```swift
@Suite("FetchXxxUseCase 테스트")
struct FetchXxxUseCaseTests {

    @Test("성공 케이스")
    func fetch_success() async throws {
        let mockRepo = MockXxxRepository()
        mockRepo.dataToReturn = Entity.sample
        let sut = FetchXxxUseCase(repository: mockRepo)

        let result = try await sut.execute()

        #expect(result != nil)
        #expect(mockRepo.fetchCallCount == 1)
    }

    @Test("네트워크 에러")
    func fetch_networkError_throws() async {
        let mockRepo = MockXxxRepository()
        mockRepo.errorToThrow = AppError.network(.noInternet)
        let sut = FetchXxxUseCase(repository: mockRepo)

        await #expect(throws: AppError.self) {
            try await sut.execute()
        }
    }
}
```

### Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Test file | `{UseCase}Tests.swift` | `FetchHomeInfoUseCaseTests.swift` |
| Mock | `Mock{Repository}.swift` | `MockHobbyRepository.swift` |
| Fixture | `{Entity}+Fixture.swift` | `HomeInfo+Fixture.swift` |
| Test function | `{action}_{condition}_{result}` | `fetch_networkError_throws` |

## Adding a New Screen

1. Create ViewController in `Presentation/[Feature]/ViewController/`
2. Create custom View in `Presentation/[Feature]/View/`
3. Create ViewModel in `Presentation/[Feature]/ViewModel/`
4. Add navigation logic to appropriate Coordinator
5. Use SnapKit for layout, Then for configuration

## UI Component Coding Style

**CRITICAL**: All UI components must follow this exact structure.

### File Structure

```swift
import UIKit
import SnapKit
import Then

final class ComponentName: UIView {

    // MARK: - UI Components

    private let componentA = UIView()
    private let componentB = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with model: SomeModel) {
        // Configure UI with model data
    }
}

// MARK: - Setup

extension ComponentName {
    private func style() {
        componentA.do {
            $0.backgroundColor = .systemGray5
            $0.layer.cornerRadius = 12
        }

        componentB.do {
            $0.textColor = .neutral600
        }
    }

    private func layout() {
        addSubview(componentA)
        addSubview(componentB)

        componentA.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
    }
}
```

### Key Rules

1. **Component Declaration at Top** - Simple initialization, no `.then {}` at declaration
2. **Split Setup Methods** - `style()` for appearance, `layout()` for constraints
3. **Use `.do {}` for Configuration** - Inside `style()` method
4. **Extension for Setup** - Keep `style()` and `layout()` methods private

### Typography System

**Location**: `Forday/Resource/Typography/`

**Never use** `.systemFont()` or `.font = UIFont(...)`
**Always use** Typography extension methods:

```swift
// ❌ WRONG
nicknameLabel.font = .systemFont(ofSize: 10, weight: .regular)

// ✅ CORRECT
nicknameLabel.setTextWithTypography("닉네임", style: .label10)
// OR
nicknameLabel.applyTypography(.label10)
```

**Available Styles**:
- Headers (Bold): `.header24`, `.header22`, `.header20`, `.header18`, `.header16`, `.header14`
- Body (Medium): `.body16`, `.body14`, `.body12`
- Labels (Regular): `.label16`, `.label14`, `.label12`, `.label10`

### Image Assets System

**Location**: `Forday/Resource/Image/Assets.xcassets/`

**Access Pattern**:
```swift
imageView.image = .My.main
imageView.image = .Icon.checkCircle
imageView.image = .Hobbycard.drawing
```

### Preview Code

**Always wrap `#Preview` with `#if DEBUG`**:

```swift
#if DEBUG
#Preview("ComponentName") {
    let view = ComponentName()
    return view
}
#endif
```

## Working with Mock Data

- DEBUG builds support mock data fallback
- Located in repositories (e.g., `ActivityRepository.makeMockActivityList()`)
- Allows offline development without API

## Screen Refresh & Event Handling Patterns

**CRITICAL**: 화면 전환 방식에 따라 데이터 새로고침 방법이 달라집니다.

### 화면 전환 케이스 분류

| 전환 방식 | viewWillAppear 호출 | 새로고침 방법 |
|----------|-------------------|-------------|
| Navigation Push → Pop | ✅ 호출됨 | `viewWillAppear`에서 처리 |
| Fullscreen Modal → Dismiss | ✅ 호출됨 | `viewWillAppear`에서 처리 |
| BottomSheet → Dismiss | ❌ 미호출 | `AppEventBus`로 처리 |
| PageSheet Modal → Dismiss | ❌ 미호출 | `AppEventBus`로 처리 |

### AppEventBus 사용 원칙

```swift
// 1. 바텀시트/PageSheet에서만 AppEventBus로 새로고침 트리거
AppEventBus.shared.activityRecordCreated
    .receive(on: DispatchQueue.main)
    .sink { [weak self] hobbyId in
        self?.loadHomeData(hobbyId: hobbyId)
    }
    .store(in: &cancellables)

// 2. Navigation/Fullscreen은 viewWillAppear가 처리 → 별도 구독 불필요
```

### 현재 선택된 상태 유지 패턴

다른 화면에서 돌아올 때 현재 선택된 상태(예: hobbyId)를 유지해야 하는 경우:

```swift
// ❌ WRONG - 서버가 기본값으로 결정
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadHomeData()  // hobbyId: nil → 서버가 결정
}

// ✅ CORRECT - 현재 선택된 상태 유지
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadHomeData(hobbyId: viewModel.currentHobbyId)  // 선택된 취미 유지
}
```

### AppEventBus에서 hobbyId 전달

```swift
// 이벤트 발행 시 hobbyId 포함
AppEventBus.shared.activityRecordCreated.send(hobbyId)

// 이벤트 수신 시 hobbyId 사용
.sink { [weak self] hobbyId in
    self?.loadHomeData(hobbyId: hobbyId)  // ✅ hobbyId 전달
}

// ❌ WRONG - hobbyId 무시
.sink { [weak self] _ in
    self?.loadHomeData()  // hobbyId 없이 호출
}
```

### HomeViewController 예시

```swift
private func bindAppEvents() {
    // 바텀시트에서 활동 저장 후 홈 새로고침
    // (바텀시트 dismiss 시 viewWillAppear가 호출되지 않으므로 이벤트로 처리)
    AppEventBus.shared.activityRecordCreated
        .receive(on: DispatchQueue.main)
        .sink { [weak self] hobbyId in
            self?.loadHomeData(hobbyId: hobbyId)
        }
        .store(in: &cancellables)

    // NOTE: activityDeleted, hobbyCreated, hobbySettingsUpdated 등
    // Navigation push/fullscreen modal에서 발생하는 이벤트는
    // dismiss/pop 시 viewWillAppear에서 currentHobbyId를 유지하며 자동 새로고침됨
    // → 별도 구독 불필요 (중복 호출 방지)
}
```

### 중복 호출 방지

Navigation Pop 케이스에서 AppEventBus와 viewWillAppear 둘 다 구독하면 중복 호출 발생:

```swift
// ❌ WRONG - 중복 호출
// 1. activityDeleted 이벤트 발생 → loadHomeData() 호출
// 2. Navigation pop → viewWillAppear → loadHomeData() 다시 호출

// ✅ CORRECT - viewWillAppear만 처리
// Navigation pop → viewWillAppear → loadHomeData(hobbyId: currentHobbyId)
```
