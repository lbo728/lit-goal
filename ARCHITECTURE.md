# 프로젝트 아키텍처

이 프로젝트는 Flutter 공식 아키텍처 가이드라인을 따라 구성되었습니다.

## 아키텍처 개요

본 프로젝트는 **MVVM (Model-View-ViewModel)** 패턴을 기반으로 하며, 다음과 같은 계층 구조를 가집니다:

- **UI Layer**: 사용자 인터페이스와 상태 관리
- **Domain Layer**: 비즈니스 로직과 데이터 모델
- **Data Layer**: 데이터 접근 및 외부 API 통신

## 폴더 구조

```
lib/
├── ui/                          # UI Layer
│   ├── core/                    # 공통 UI 컴포넌트
│   │   └── ui/                  # 재사용 가능한 위젯
│   ├── home/                    # 홈 피처
│   │   ├── view_model/          # 홈 뷰모델
│   │   └── widgets/             # 홈 화면 위젯
│   ├── book/                    # 책 관련 피처
│   │   ├── view_model/          # 책 뷰모델
│   │   └── widgets/             # 책 관련 화면 위젯
│   ├── reading/                 # 독서 관련 피처
│   │   ├── view_model/          # 독서 뷰모델
│   │   └── widgets/             # 독서 관련 화면 위젯
│   └── calendar/                # 캘린더 피처
│       ├── view_model/          # 캘린더 뷰모델
│       └── widgets/             # 캘린더 화면 위젯
├── domain/                      # Domain Layer
│   └── models/                  # 도메인 모델
├── data/                        # Data Layer
│   ├── repositories/            # 리포지토리 (데이터 접근 추상화)
│   └── services/                # 서비스 (외부 API, 로컬 데이터)
├── config/                      # 앱 설정
├── utils/                       # 유틸리티 함수
├── routing/                     # 라우팅 설정
└── main.dart                    # 앱 진입점
```

## 아키텍처 원칙

### 1. 관심사의 분리 (Separation of Concerns)

- **UI Layer**: 화면 표시와 사용자 상호작용만 담당
- **Domain Layer**: 비즈니스 로직과 데이터 모델 정의
- **Data Layer**: 데이터 접근과 외부 통신 담당

### 2. 의존성 주입 (Dependency Injection)

- `Provider` 패키지를 사용하여 의존성 관리
- 인터페이스를 통한 느슨한 결합
- 테스트 가능한 구조

### 3. MVVM 패턴

- **View**: Flutter Widget (화면)
- **ViewModel**: `ChangeNotifier`를 상속한 상태 관리 클래스
- **Model**: 도메인 모델과 리포지토리

## 주요 컴포넌트

### Repository Pattern

```dart
abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<Book?> addBook(Book book);
  // ... 기타 메서드
}

class BookRepositoryImpl implements BookRepository {
  final BookService _bookService;
  // 구현...
}
```

### ViewModel Pattern

```dart
class HomeViewModel extends ChangeNotifier {
  final BookRepository _bookRepository;

  // 상태 관리
  bool _isLoading = false;
  String? _errorMessage;

  // 비즈니스 로직
  Future<void> loadBooks() async {
    // 구현...
  }
}
```

### Provider 설정

```dart
MultiProvider(
  providers: [
    Provider<BookService>(create: (_) => BookService()),
    Provider<BookRepository>(create: (context) => BookRepositoryImpl(...)),
    ChangeNotifierProvider<HomeViewModel>(create: (context) => HomeViewModel(...)),
  ],
  child: MaterialApp(...),
)
```

## 데이터 흐름

1. **View**에서 사용자 액션 발생
2. **ViewModel**의 메서드 호출
3. **ViewModel**이 **Repository**를 통해 데이터 요청
4. **Repository**가 **Service**를 통해 실제 데이터 처리
5. 결과를 **ViewModel**로 반환
6. **ViewModel**이 상태 업데이트 (`notifyListeners()`)
7. **View**가 자동으로 리빌드

## 테스트 전략

- **Unit Test**: ViewModel과 Repository의 비즈니스 로직 테스트
- **Widget Test**: 개별 위젯의 UI 테스트
- **Integration Test**: 전체 사용자 플로우 테스트

## 확장성

이 아키텍처는 다음과 같은 이점을 제공합니다:

1. **모듈성**: 각 피처가 독립적으로 개발 가능
2. **테스트 용이성**: 각 계층을 독립적으로 테스트 가능
3. **유지보수성**: 명확한 책임 분리로 코드 수정이 용이
4. **확장성**: 새로운 피처 추가가 간단

## 참고 자료

- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter Architecture Case Study](https://docs.flutter.dev/app-architecture/case-study)
- [Provider Package Documentation](https://pub.dev/packages/provider)
