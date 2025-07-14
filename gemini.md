# Lit-Goal 프로젝트 분석 및 기획서

## 1. 프로젝트 개요

**Lit-Goal**은 사용자가 자신의 독서 목표를 설정하고, 독서 과정을 추적하며, 독서 습관을 시각적으로 관리할 수 있도록 돕는 모바일 애플리케이션입니다. 알라딘 API를 통해 도서 정보를 가져오고, Supabase를 백엔드로 사용하여 사용자 데이터와 독서 기록을 관리합니다.

## 2. 핵심 목표

-   사용자에게 직관적인 독서 기록 및 관리 기능을 제공합니다.
-   독서량, 독서 시간 등의 데이터를 차트로 시각화하여 동기를 부여합니다.
-   손쉬운 도서 검색 및 추가를 통해 사용자 편의성을 높입니다.

## 3. 주요 기능 (분석 기반)

### 3.1. 사용자 인증 (`auth`)
-   **기능:** 사용자는 계정을 생성하고 로그인하여 개인화된 서비스를 이용할 수 있습니다.
-   **구현 파일:**
    -   `lib/ui/auth/widgets/login_screen.dart`: 로그인 UI
    -   `lib/ui/auth/widgets/my_page_screen.dart`: 마이페이지 UI
    -   `lib/data/services/auth_service.dart`: 인증 로직 (Supabase 연동)
    -   `assets/images/logo-google.svg`: 구글 소셜 로그인 지원 암시

### 3.2. 도서 검색 및 관리 (`book`)
-   **기능:** 알라딘 API를 통해 국내 도서를 검색하고, 자신의 서재에 추가하거나 상세 정보를 확인할 수 있습니다.
-   **구현 파일:**
    -   `lib/data/services/aladin_api_service.dart`: 알라딘 API 연동
    -   `lib/data/repositories/book_repository.dart`: 도서 데이터 관리
    -   `lib/ui/book/widgets/book_list_screen.dart`: 도서 목록 UI
    -   `lib/ui/book/widgets/book_detail_screen.dart`: 도서 상세 정보 UI
    -   `lib/domain/models/book.dart`: 도서 데이터 모델

### 3.3. 독서 활동 추적 (`reading`)
-   **기능:** 특정 도서에 대한 독서 활동(시작, 진행, 완료)을 기록하고, 진행 상황을 추적합니다.
-   **구현 파일:**
    -   `lib/ui/reading/widgets/reading_start_screen.dart`: 독서 시작 화면
    -   `lib/ui/reading/widgets/reading_progress_screen.dart`: 독서 진행률 추적 화면
    -   `lib/ui/reading/widgets/reading_chart_screen.dart`: 독서 통계 차트 화면

### 3.4. 독서 현황 시각화 (`calendar`, `home`)
-   **기능:** 홈 화면에서 전반적인 독서 현황을 확인하고, 캘린더를 통해 자신의 월별 독서 기록을 한눈에 파악할 수 있습니다.
-   **구현 파일:**
    -   `lib/ui/home/widgets/home_screen.dart`: 메인 대시보드 UI
    -   `lib/ui/calendar/widgets/calendar_screen.dart`: 독서 기록 캘린더 UI
    -   `lib/ui/home/view_model/home_view_model.dart`: 홈 화면 상태 관리

## 4. 기술 스택 및 아키텍처

-   **프레임워크:** Flutter
-   **프로그래밍 언어:** Dart
-   **백엔드 (BaaS):** Supabase (인증, 데이터베이스)
-   **외부 API:** Aladin Book API
-   **아키텍처:** `data`, `domain`, `ui`로 분리된 계층적 아키텍처(Layered Architecture)를 채택하여 관심사를 분리하고 유지보수성을 높였습니다.
    -   **UI Layer:** 화면과 사용자 인터랙션 담당
    -   **Domain Layer:** 핵심 비즈니스 로직 및 데이터 모델 정의
    -   **Data Layer:** 데이터 소스(API, DB)와의 통신 및 데이터 관리

## 5. 데이터 모델

-   **User (`user_model.dart`):** 사용자 정보 (ID, 이메일, 프로필 사진 등)
-   **Book (`book.dart`):** 도서 정보 (제목, 저자, ISBN, 표지 이미지 등)
-   **ReadingProgress (추정):** 사용자와 책을 연결하고 독서 진행 상태(읽은 페이지, 상태 등)를 저장하는 모델
-   **ReadingSession (추정):** 개별 독서 시간(시작 시간, 종료 시간, 읽은 분량)을 기록하는 모델

## 7. iOS 앱 스토어 런칭을 위한 추가 과제

현재 Lit-Goal 프로젝트는 핵심 기능의 프로토타입이 잘 구현되어 있으나, 정식으로 iOS 앱 스토어에 런칭하기 위해서는 다음의 과제들을 완료해야 합니다.

### 7.1. 기능 완성도 높이기

-   **사용자 온보딩:** 앱을 처음 사용하는 유저를 위한 온보딩 프로세스가 필요합니다. 앱의 핵심 기능을 안내하는 튜토리얼이나 가이드 화면을 추가하여 사용자의 초기 이탈을 방지해야 합니다.
-   **마이페이지 기능 구체화:** 현재 `my_page_screen.dart`는 기본적인 틀만 존재합니다. 프로필 이미지 변경, 닉네임 수정, 비밀번호 변경, 로그아웃, 회원 탈퇴 등 구체적인 사용자 정보 관리 기능을 구현해야 합니다.
-   **알림 기능:** 사용자가 설정한 독서 목표일이 다가오거나, 며칠간 독서 기록이 없을 경우 푸시 알림을 보내주는 기능을 추가하여 사용자 리텐션을 높일 수 있습니다. (Firebase Cloud Messaging 또는 Supabase Edge Function 활용)
-   **오류 처리 고도화:** 현재 `try-catch`로 기본적인 오류는 처리하고 있으나, 네트워크 연결 없음, API 타임아웃, 서버 오류 등 다양한 예외 상황에 대한 사용자 친화적인 오류 메시지와 대응 방안(예: 재시도 버튼)이 필요합니다.

### 7.2. 사용자 경험(UX/UI) 개선

-   **전체적인 디자인 일관성:** 앱 전반의 컬러, 폰트, 아이콘, 컴포넌트 스타일을 통일성 있게 다듬어야 합니다. `app_config.dart` 등을 활용하여 디자인 시스템을 구축하고, 모든 화면에 일관되게 적용해야 합니다.
-   **로딩 및 스켈레톤 UI:** 데이터를 불러오는 동안 사용자가 지루함을 느끼지 않도록 `CircularProgressIndicator` 외에 스켈레톤 UI(콘텐츠의 윤곽을 먼저 보여주는 방식)를 적용하여 더 나은 사용자 경험을 제공해야 합니다.
-   **애니메이션 및 트랜지션:** 화면 전환, 버튼 클릭, 데이터 업데이트 시 부드러운 애니메이션 효과를 추가하여 앱의 완성도를 높이고 사용자의 긍정적인 인식을 유도할 수 있습니다.
-   **기기별 해상도 대응:** 다양한 iOS 기기(iPhone SE, Pro, Pro Max 등)의 화면 크기와 해상도에 맞게 UI가 깨지지 않고 자연스럽게 표시되는지 테스트하고 수정해야 합니다. (Flutter의 `LayoutBuilder`, `MediaQuery` 활용)

### 7.3. 안정성 및 프로덕션 준비

-   **상태 관리 전략 확립:** 현재 `StatefulWidget`의 `setState`를 주로 사용하고 있습니다. 앱의 규모가 커질 것을 대비하여 Provider, Riverpod, BLoC 등 보다 체계적인 상태 관리 라이브러리를 도입하여 데이터 흐름을 효율적으로 관리하고 예측 가능성을 높여야 합니다.
-   **테스트 코드 작성:** `widget_test.dart` 외에 주요 기능(인증, 데이터 CRUD, 비즈니스 로직)에 대한 단위 테스트(Unit Test)와 통합 테스트(Integration Test) 코드를 작성하여 코드의 안정성을 확보하고, 향후 리팩토링 시 발생할 수 있는 문제를 사전에 방지해야 합니다.
-   **iOS 관련 설정:**
    -   **앱 아이콘 및 스플래시 화면:** `ios/Runner/Assets.xcassets`에 다양한 해상도의 앱 아이콘을 등록하고, 앱 로딩 시 보여줄 스플래시 화면을 디자인하여 적용해야 합니다.
    -   **권한 설정:** 카메라, 사진 라이브러리 접근 권한이 필요한 경우, `Info.plist` 파일에 `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` 등 사용자에게 보여줄 권한 요청 메시지를 명확하게 작성해야 합니다.
    -   **앱 이름(Bundle Name) 및 버전 관리:** `Info.plist`와 `pubspec.yaml`에서 앱의 최종 이름과 버전을 설정하고, 앱 스토어 등록을 위한 빌드 번호를 관리해야 합니다.
-   **보안 강화:**
    -   **API 키 및 민감 정보 관리:** 현재 코드에 하드코딩되었을 수 있는 Aladin API 키, Supabase URL 및 키 등을 `.env` 파일과 `flutter_dotenv` 같은 라이브러리를 사용하여 분리하고, Git 추적에서 제외하여 보안을 강화해야 합니다.
    -   **Supabase Row Level Security (RLS):** Supabase 데이터베이스의 각 테이블에 RLS 정책을 설정하여, 인증된 사용자가 자신의 데이터에만 접근하고 수정할 수 있도록 서버 단에서 보안을 강화해야 합니다.
-   **앱 스토어 심사 준비:** Apple의 앱 스토어 심사 가이드라인을 숙지하고, 앱이 모든 정책을 준수하는지 확인해야 합니다. (예: 사용자 데이터 처리 방침, 앱 내 결제 정책 등)
