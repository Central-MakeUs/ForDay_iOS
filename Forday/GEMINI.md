# GEMINI.md - ForDay Project Mandates

This file contains foundational mandates for the **ForDay** project. These instructions take absolute precedence over general workflows and tool defaults.

## 🏗 Architecture & Design Patterns

- **Clean Architecture (5 Layers)**: Strictly maintain boundaries between Data, Domain, and Presentation layers.
- **MVVM-C Pattern**: Use Model-View-ViewModel with Coordinator for navigation.
  - NEVER push or present directly from ViewControllers.
  - Use `Coordinator` for all navigation logic.
- **Dependency Flow**: 
  - `Presentation (ViewModel) -> Domain (UseCase) -> Domain (Repository Interface) <- Data (Repository Implementation)`.
  - Keep **DTOs** in the Data layer and **Entities** in the Domain layer. Never mix them.
- **Reactive Framework**: Use **Combine** for data binding and event handling.

## 🛠 Technical Standards

- **UI Implementation**: 
  - Use **UIKit** with **SnapKit** for layouts.
  - Use **Then** for component configuration.
  - Follow the `style()` / `layout()` pattern in UI components.
- **Networking**: 
  - Use **Moya** + **Alamofire** for all network requests.
  - Requests MUST go through service classes using Moya.
  - Use `MoyaProvider+Async` extension for automatic error parsing and async/await support.
  - **Token Management**: Handled automatically via interceptors; do not bypass.
- **Image Loading**: Use **Kingfisher**.
- **Storage**: Use the provided **Keychain wrapper** for sensitive data.
- **Typography**: Adhere to the established `TypographyStyle` and `Pretendard` fonts.

## ⚠️ Error Handling

- **AppError**: Use the unified `AppError` type (Network, Server, Decoding, Unknown).
- **ViewModel Responsibility**: Catch errors and expose them via `@Published var error: AppError?`.
- **ViewController Responsibility**: Bind to the error property and handle UI display (Alert, Toast, or Empty State).
- **Safety**: NEVER use `try!` for operations that can fail. Use `try?` or `do-catch`.

## 🧪 Testing Requirements

- **MANDATORY**: All **UseCases** MUST have corresponding unit tests.
- Refer to `FordayTests/UseCase/` for existing test patterns.

## 📝 Coding Conventions

- **File Headers**: Use `"Created by Subeen"` for all new file headers.
- **Naming**: 
  - Repository interfaces: `<Feature>RepositoryInterface`.
  - Repository implementations: `<Feature>Repository`.
  - UseCases: `<Action><Feature>UseCase`.
- **Project Structure**:
  - Code resides in `Forday/Source/`.
  - Resources reside in `Forday/Resource/`.

## 🚀 Workflow & Source Control

- **Build Actions**:
  - Do not run build actions such as `xcodebuild`, Xcode builds, or simulator launches unless the user explicitly asks.
  - The user will handle build verification locally.
- **Branching Strategy**:
  - Main branch: `develop`.
  - Feature branches: `feature/#<issue-number>/<description>`.
  - Bugfix branches: `bugfix/#<issue-number>/<description>`.
- **Feature Implementation Steps**:
  1. Explain the code structure and affected files first.
  2. Ask clarifying questions if requirements are ambiguous.
  3. Implement following existing patterns.
  4. Add mandatory unit tests.

## 📂 Quick Reference

- **Xcode Project**: `Forday.xcodeproj`
- **Build Scheme**: `Forday`
- **Minimum Deployment Target**: See project settings.
