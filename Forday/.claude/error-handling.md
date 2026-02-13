# Error Handling System

ForDay iOS 앱의 에러 처리 시스템 가이드입니다.

## Error Architecture

ForDay uses a structured error handling system that provides user-friendly error messages and appropriate recovery actions.

**Error Types** (`Domain/Error/AppError.swift`):

```swift
enum AppError: Error {
    case network(NetworkError)     // Network connectivity issues
    case server(ServerError)        // Server-side errors (4xx, 5xx)
    case decoding(DecodingError)    // JSON parsing failures
    case unknown(Error)             // Unexpected errors
}
```

## Network Errors

```swift
enum NetworkError: Error {
    case noInternet        // "인터넷 연결을 확인해주세요."
    case timeout           // "요청 시간이 초과되었습니다.\n다시 시도해주세요."
    case cancelled         // "요청이 취소되었습니다."
    case unknown           // "네트워크 오류가 발생했습니다."
}
```

## Server Errors

Server errors automatically parse the server response:

```json
{
  "status": 404,
  "success": false,
  "data": {
    "errorClassName": "ACTIVITY_RECORD_NOT_FOUND",
    "message": "존재하지 않는 활동 기록입니다."
  }
}
```

↓ Converted to:

```swift
ServerError(
    errorClassName: "ACTIVITY_RECORD_NOT_FOUND",
    message: "존재하지 않는 활동 기록입니다.",
    statusCode: 404
)
```

## Error Handling in ViewModels

**Pattern to follow**:

```swift
class MyViewModel {
    @Published var error: AppError?  // Use AppError, not String

    func fetchData() async {
        do {
            let result = try await useCase.execute()
            // success
        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
            }
        }
    }
}
```

## Error Handling in ViewControllers

**Basic pattern**:

```swift
viewModel.$error
    .compactMap { $0 }
    .sink { [weak self] error in
        self?.handleError(error)
    }
    .store(in: &cancellables)

private func handleError(_ error: AppError) {
    let alert = UIAlertController(
        title: "오류",
        message: error.userMessage,
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
}
```

## UIViewController Error Handling Extensions

All ViewControllers automatically have access to these error handling methods via `UIViewController+ErrorHandling.swift`:

| Method | Description | Use Case |
|--------|-------------|----------|
| `handleActivityRecordError(_:customHandler:)` | 활동 기록 API 에러 처리 | POST /records, PATCH /records |
| `handleActivityDetailError(_:onRetry:)` | 활동 상세 API 에러 처리 (재시도 지원) | GET /records/{id} |
| `handleUserError(_:customHandler:)` | 사용자 API 에러 처리 | GET /users, POST /users/nickname |
| `handleHobbyError(_:customHandler:)` | 취미 API 에러 처리 | GET /hobbies, POST /hobbies |
| `handleAppError(_:using:customHandler:)` | 범용 에러 처리 | Custom APIs |

**Usage**:

```swift
// ✅ BEST: Use convenience method
func someAsyncOperation() async {
    do {
        try await useCase.execute()
    } catch let error as AppError {
        handleActivityRecordError(error)
    }
}

// ✅ GOOD: With retry support
viewModel.$error
    .compactMap { $0 }
    .sink { [weak self] error in
        self?.handleActivityDetailError(error) {
            self?.loadData()  // Retry action
        }
    }
    .store(in: &cancellables)
```

## Server Error Code Management

**CRITICAL**: All server error codes are centrally managed in `Domain/Error/ServerErrorCode.swift`.

**Benefits**:
- ✅ Type-safe error handling (no string typos)
- ✅ API-specific error metadata
- ✅ Consistent recovery actions across the app
- ✅ Self-documenting code

**Adding New API Errors**:

1. Add error code constant to `ServerErrorCode`:
```swift
static let newErrorCode = "NEW_ERROR_CODE"
```

2. Add metadata mapping to appropriate API enum:
```swift
enum MyAPIError {
    static let metadata: [String: APIErrorMetadata] = [
        ServerErrorCode.newErrorCode: APIErrorMetadata(
            code: ServerErrorCode.newErrorCode,
            title: "User-Friendly Title",
            action: .dismiss
        )
    ]
}
```

3. Add extension to `ServerError`:
```swift
extension ServerError {
    var myAPIMetadata: APIErrorMetadata? {
        return MyAPIError.metadata[errorClassName]
    }
}
```

## Common Server Error Classes

### Activity Record Errors

| Error Class | Status | User Message | Recovery |
|-------------|--------|--------------|----------|
| `ACTIVITY_NOT_FOUND` | 404 | "존재하지 않는 활동입니다." | Dismiss |
| `NOT_ACTIVITY_OWNER` | 403 | "활동 소유자가 아닙니다." | Dismiss |
| `S3_IMAGE_NOT_FOUND` | 404 | "S3에 해당 이미지가 존재하지 않습니다." | Retry upload |
| `ALREADY_RECORDED_TODAY` | 400 | "오늘 해당 취미에 대한 활동 기록을 이미 작성하였습니다." | Dismiss |
| `INVALID_HOBBY_STATUS` | 400 | "현재 취미 상태에서는 해당 작업을 수행할 수 없습니다." | Dismiss |
| `STICKER_COMPLETION_REACHED` | 400 | "해당 취미의 스티커 수가 이미 최대치에 도달했습니다." | Dismiss |

### Activity Detail Errors

| Error Class | Status | User Message | Recovery |
|-------------|--------|--------------|----------|
| `ACTIVITY_RECORD_NOT_FOUND` | 404 | "존재하지 않는 활동 기록입니다." | Navigate back |
| `FRIEND_ONLY_ACCESS` | 403 | "이 글은 친구만 조회할 수 있습니다." | Navigate back |
| `PRIVATE_RECORD` | 403 | "이 글은 작성자만 볼 수 있습니다." | Navigate back |

### Auth Errors

| Error Class | Status | User Message | Recovery |
|-------------|--------|--------------|----------|
| `TOKEN_EXPIRED` | 401 | Auto-handled | Auto-retry |
| `LOGIN_EXPIRED` | 401 | Auto-handled | Navigate to login |

### User Errors

| Error Class | Status | User Message | Recovery |
|-------------|--------|--------------|----------|
| `NICKNAME_DUPLICATED` | 409 | "이미 사용 중인 닉네임입니다." | None |
| `USER_NOT_FOUND` | 404 | "존재하지 않는 사용자입니다." | Navigate back |

### Hobby Errors

| Error Class | Status | User Message | Recovery |
|-------------|--------|--------------|----------|
| `HOBBY_NOT_FOUND` | 404 | "존재하지 않는 취미입니다." | Navigate back |
| `HOBBY_LIMIT_EXCEEDED` | 400 | "취미는 최대 2개까지 등록할 수 있습니다." | None |

## Automatic Error Parsing

The `MoyaProvider+Async` extension automatically:
1. Detects HTTP error status codes (4xx, 5xx)
2. Parses server error responses
3. Converts MoyaErrors to AppErrors
4. Provides user-friendly error messages

**No additional work needed** - just use `try await provider.request()`.
