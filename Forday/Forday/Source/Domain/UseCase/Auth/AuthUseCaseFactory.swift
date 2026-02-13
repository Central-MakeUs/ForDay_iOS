//
//  AuthUseCaseFactory.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


// Domain/UseCase/Auth/AuthUseCaseFactory.swift
struct AuthUseCaseFactory {

    private let authRepository: AuthRepositoryInterface
    private let kakaoAuthService: SocialAuthService
    private let appleAuthService: AppleAuthService
    private let tokenStorage: TokenStorage

    init(
        authRepository: AuthRepositoryInterface = AuthRepository(),
        kakaoAuthService: SocialAuthService = KakaoAuthService(),
        appleAuthService: AppleAuthService = AppleAuthService(),
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.authRepository = authRepository
        self.kakaoAuthService = kakaoAuthService
        self.appleAuthService = appleAuthService
        self.tokenStorage = tokenStorage
    }

    func makeKakaoLoginUseCase() -> KakaoLoginUseCase {
        return KakaoLoginUseCase(
            kakaoAuthService: kakaoAuthService,
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }

    func makeAppleLoginUseCase() -> AppleLoginUseCase {
        return AppleLoginUseCase(
            appleAuthService: appleAuthService,
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }

    func makeGuestLoginUseCase() -> GuestLoginUseCase {
        return GuestLoginUseCase(
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }

    func makeSwitchToKakaoUseCase() -> SwitchToKakaoUseCase {
        return SwitchToKakaoUseCase(
            kakaoAuthService: kakaoAuthService,
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }

    func makeSwitchToAppleUseCase() -> SwitchToAppleUseCase {
        return SwitchToAppleUseCase(
            appleAuthService: appleAuthService,
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }

    func makeAutoLoginUseCase() -> AutoLoginUseCase {
        return AutoLoginUseCase(
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }
}
