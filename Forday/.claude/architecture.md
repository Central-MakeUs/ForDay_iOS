# Architecture Guide

ForDay iOS 앱의 아키텍처 및 디렉토리 구조 가이드입니다.

## Clean Architecture with 5 Layers

```
┌─────────────────────────────────────────┐
│          Application Layer              │  AppDelegate, SceneDelegate
├─────────────────────────────────────────┤
│         Presentation Layer              │  ViewControllers, Views, ViewModels, Coordinators
├─────────────────────────────────────────┤
│           Domain Layer                  │  Entities, UseCases, Repository Interfaces
├─────────────────────────────────────────┤
│            Data Layer                   │  Repositories, Network (Moya), DTOs
├─────────────────────────────────────────┤
│       Infrastructure Layer              │  Keychain, Kakao Auth
└─────────────────────────────────────────┘
```

## Key Patterns

**Coordinator Pattern** - All navigation flows through coordinators:
- `AppCoordinator`: Root coordinator, validates tokens and routes to Auth or MainTabBar
- `AuthCoordinator`: Manages login/onboarding flow
- `MainTabBarCoordinator`: Manages 5-tab structure (Home, Discovery, Write, News, My)

**Repository Pattern** - All data access abstracted:
- Interfaces in `Domain/RepositoryInterface/`
- Implementations in `Data/Repository/`
- Repositories convert DTOs to Domain entities

**MVVM with Combine**:
- ViewModels expose `@Published` properties
- ViewControllers bind via Combine subscriptions
- Custom UIView subclasses handle layout (using SnapKit)

**Use Case Pattern** - Business logic encapsulation:
- Located in `Domain/UseCase/`
- Orchestrate repository calls and business rules
- Example: `KakaoLoginUseCase` handles OAuth flow → API exchange → token storage

## Critical Architecture Components

### Token Management & Authentication

**Token Lifecycle**:
1. **App Launch**: `TokenManager.validateTokenOnAppLaunch()` checks validity
2. **Auto-refresh**: `TokenRefreshInterceptor` handles 401 responses
3. **Storage**: Tokens stored in Keychain via `TokenStorage`
4. **Expiration handling**:
   - `LOGIN_EXPIRED`: Routes to login screen via `SceneDelegate.showLoginScreen()`
   - `TOKEN_EXPIRED`: Automatically refreshes and retries request

**TokenRefreshInterceptor** (`Data/Network/Interceptor/TokenRefreshInterceptor.swift`):
- Implements Alamofire `RequestInterceptor`
- **adapt()**: Injects Bearer token before each request
- **retry()**: On 401, refreshes token and retries original request
- Uses queue system to prevent duplicate refresh calls
- Critical for maintaining user session

**Flow on App Launch**:
```
AppDelegate → SceneDelegate.scene(_:willConnectTo:)
  → AppCoordinator.start()
    → TokenManager.validateTokenOnAppLaunch()
      → Valid? → MainTabBarCoordinator
      → Invalid? → AuthCoordinator
```

### Network Layer (Moya + Alamofire)

**Structure**:
- `NetworkProvider`: Factory creating MoyaProviders with/without token interceptors
- `BaseTargetType`: Protocol extending Moya's TargetType
- Service classes: `AuthService`, `ActivityService`, `UsersService`, `AppService`
- API definitions in `Data/Network/API/Endpoint/` (e.g., `AuthAPI`, `HobbiesAPI`)

**API Constants** (`Data/Network/Base/APIConstants.swift`):
- Base URL configuration
- Shared headers

**Auto-token injection**: All API requests automatically include Bearer token via interceptor

### Keychain Storage

Located: `Infrastructure/Keychain/`

**TokenStorage**:
```swift
func saveTokens(accessToken: String, refreshToken: String)
func loadAccessToken() throws -> String
func loadRefreshToken() throws -> String
func deleteAllTokens()
```

**OnboardingDataStorage**: Persists user hobby selections during onboarding

### Social Authentication

**Kakao Login**:
- `KakaoAuthService` wraps Kakao SDK
- URL scheme handling in `SceneDelegate.scene(_:openURLContexts:)`
- Info.plist contains Kakao App Key: `$(KAKAO_APP_KEY)` (build variable)
- URL scheme: `kakao4a8c46b5ba89a1e9b3617f277c8f4e85`

## Directory Structure

```
Forday/Source/
├── Application/           # App lifecycle (AppDelegate, SceneDelegate)
├── Presentation/          # UI layer
│   ├── Auth/             # Login screen
│   ├── Onboarding/       # Multi-step onboarding (internal numbered folders)
│   ├── Home/             # Home tab
│   ├── ActivityRecord/   # Activity creation/viewing
│   ├── Stories/          # Story feed
│   ├── My/               # Profile/settings
│   ├── Common/           # Shared UI components
│   └── Coordinator/      # Navigation coordinators
├── Domain/               # Business logic
│   ├── Entity/           # Domain models (Activity, User, Hobby, etc.)
│   ├── RepositoryInterface/ # Repository contracts
│   ├── UseCase/          # Business logic (Auth, Activity, User, App)
│   └── Manager/          # TokenManager
├── Data/                 # Data access
│   ├── Network/
│   │   ├── Base/         # NetworkProvider, BaseTargetType, APIConstants
│   │   ├── API/Service/  # Service clients
│   │   ├── API/Endpoint/ # API definitions
│   │   ├── TargetType/   # Moya implementations
│   │   ├── DTO/          # Request/Response models
│   │   ├── Interceptor/  # TokenRefreshInterceptor
│   │   └── Plugin/       # MoyaLoggingPlugin
│   └── Repository/       # Repository implementations
└── Infrastructure/       # 3rd-party integrations
    ├── Keychain/         # Secure storage
    └── KakaoAuth/        # Kakao SDK wrapper
```

## Presentation Folder Structure Rules

**CRITICAL**: Follow these folder naming conventions for the Presentation layer.

### Top-Level Feature Folders

Top-level folders use **feature names without numbers**:

```
Presentation/
├── Auth/              # 로그인/회원가입
├── Onboarding/        # 온보딩 플로우
├── Home/              # 홈 탭
├── ActivityRecord/    # 활동 기록
├── Stories/           # 스토리 피드
├── My/                # 마이페이지
├── Common/            # 공통 컴포넌트
└── Coordinator/       # 내비게이션 코디네이터
```

**Rules**:
- ❌ `0. Auth/`, `1. Onboarding/` - 숫자 접두사 사용 금지
- ✅ `Auth/`, `Onboarding/` - 기능명만 사용

### Onboarding Internal Folders (Exception)

Onboarding 내부 폴더는 **순차적 화면 흐름**을 나타내므로 **숫자 접두사 사용**:

```
Onboarding/
├── 1. GoalSelection/       # 목표 선택
├── 2. TimeSelection/       # 시간 선택
├── 3. HobbySelection/      # 취미 선택
├── 4. FrequencySelection/  # 빈도 선택
├── 5. PeriodSelection/     # 기간 선택
├── 6. OnboardingStart/     # 온보딩 시작
├── 7. Nickname/            # 닉네임 설정
└── 8. OnboardingComplete/  # 완료
```

### Standard Feature Folder Structure

각 기능 폴더 내부 구조:

```
{Feature}/
├── ViewController/      # UIViewController 서브클래스
├── View/               # Custom UIView 서브클래스
├── ViewModel/          # ViewModels (MVVM)
└── Cell/               # CollectionView/TableView Cells (필요 시)
```

### When to Use Numbers

| Context | Use Numbers? | Example |
|---------|--------------|---------|
| Top-level feature folders | ❌ No | `Home/`, `My/` |
| Onboarding internal folders | ✅ Yes | `1. GoalSelection/` |
| Other sequential flows | ⚠️ Case by case | 팀 논의 후 결정 |
| Non-sequential sub-features | ❌ No | `Settings/`, `Profile/` |

### Adding New Features

1. **New tab or major feature**: Create folder at `Presentation/{FeatureName}/`
2. **New screen in existing feature**: Add to existing feature folder
3. **New onboarding step**: Add numbered folder in correct sequence position
4. **Shared component**: Add to `Presentation/Common/`
