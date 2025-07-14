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

## 6. 향후 발전 방향 제안

-   **소셜 기능:** 친구와 독서 현황 공유, 독서 클럽 기능
-   **목표 설정 강화:** 연간/월간 독서 목표 설정 및 달성률 시각화
-   **추천 시스템:** 사용자의 독서 이력을 기반으로 한 도서 추천 기능
-   **알림 기능:** 설정된 독서 시간에 맞춰 푸시 알림 전송
