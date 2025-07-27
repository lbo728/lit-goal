# iOS 앱스토어 심사 거절 사유 및 개선 방안

## 개요

- **Submission ID**: 353c2924-d6e8-43ab-b784-87460cf71903
- **Review Date**: July 21, 2025
- **Version**: 1.0
- **Status**: 거절됨

## 주요 거절 사유 및 개선 방안

### 1. Guideline 2.3.10 - Performance - Accurate Metadata

**문제**: 스크린샷에 디버그 배너가 포함되어 있음

**개선 방안**:

- [ ] 릴리즈 빌드에서 디버그 배너 제거
- [ ] 앱스토어용 스크린샷을 릴리즈 빌드로 재촬영
- [ ] 개발 과정 관련 참조 제거 (앱 설명, 프로모션 텍스트, What's New 등)

**구현 방법**:

```dart
// main.dart에서 디버그 배너 제거
MaterialApp(
  debugShowCheckedModeBanner: false, // 릴리즈 빌드에서 false로 설정
  // ... 기타 설정
)
```

### 2. Guideline 4.8 - Design - Login Services

**문제**: 서드파티 로그인 서비스 사용 시 Apple의 요구사항을 충족하지 않음

**개선 방안**:

- [ ] Sign in with Apple 구현
- [ ] 다음 요구사항 충족:
  - 사용자 이름과 이메일 주소만 데이터 수집 제한
  - 이메일 주소를 모든 당사자로부터 비공개로 유지할 수 있는 옵션 제공
  - 동의 없이 광고 목적으로 앱 상호작용 수집하지 않음

**구현 방법**:

```dart
// pubspec.yaml에 의존성 추가
dependencies:
  sign_in_with_apple: ^5.0.0

// Apple 로그인 구현
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<void> signInWithApple() async {
  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );
  // 사용자 정보 처리
}
```

### 3. Guideline 1.5 - Safety

**문제**: 지원 URL이 작동하지 않음 (https://example.com)

**개선 방안**:

- [ ] 실제 작동하는 지원 웹페이지 생성
- [ ] App Store Connect에서 지원 URL 업데이트
- [ ] 사용자 지원 정보 포함

**권장 사항**:

- GitHub Pages 또는 Netlify를 사용한 간단한 지원 페이지 생성
- FAQ, 연락처 정보, 앱 사용법 등 포함

### 4. Guideline 5.1.1(v) - Data Collection and Storage

**문제**: 계정 생성은 지원하지만 계정 삭제 옵션이 없음

**개선 방안**:

- [ ] 계정 삭제 기능 구현
- [ ] 앱 내에서 직접 계정 삭제 가능하도록 구현
- [ ] 실수 방지를 위한 확인 단계 포함
- [ ] 웹사이트를 통한 삭제가 필요한 경우 직접 링크 제공

**구현 방법**:

```dart
// 계정 삭제 기능 구현
class AccountService {
  Future<void> deleteAccount(String userId) async {
    // 1. 사용자 데이터 삭제
    await _deleteUserData(userId);

    // 2. 인증 정보 삭제
    await _deleteAuthData(userId);

    // 3. 로컬 데이터 삭제
    await _clearLocalData();

    // 4. 로그아웃 처리
    await _signOut();
  }
}

// UI에서 확인 다이얼로그 표시
Future<void> _showDeleteAccountDialog() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('계정 삭제'),
      content: const Text('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await accountService.deleteAccount(userId);
  }
}
```

## 우선순위별 작업 계획

### Phase 1 (즉시 수정)

1. **디버그 배너 제거**

   - 릴리즈 빌드 설정 확인
   - 앱스토어용 스크린샷 재촬영

2. **지원 URL 수정**
   - 간단한 지원 페이지 생성
   - App Store Connect에서 URL 업데이트

### Phase 2 (핵심 기능)

3. **Sign in with Apple 구현**

   - Apple 개발자 계정에서 Sign in with Apple 활성화
   - 코드 구현 및 테스트

4. **계정 삭제 기능 구현**
   - 데이터 삭제 로직 구현
   - UI 구현 및 테스트

### Phase 3 (최적화)

5. **추가 개선사항**
   - 사용자 경험 개선
   - 성능 최적화
   - 추가 테스트

## 기술적 구현 세부사항

### 1. 릴리즈 빌드 설정

```yaml
# pubspec.yaml
flutter:
  build:
    ios:
      release:
        debugShowCheckedModeBanner: false
```

### 2. Apple 로그인 설정

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>signinwithapple</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>signinwithapple</string>
    </array>
  </dict>
</array>
```

### 3. 계정 삭제 API 구현

```dart
// data/services/auth_service.dart
class AuthService {
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Supabase에서 사용자 데이터 삭제
      await supabase
          .from('users')
          .delete()
          .eq('id', userId);

      // 인증 정보 삭제
      await supabase.auth.admin.deleteUser(userId);

      // 로컬 데이터 삭제
      await _clearLocalStorage();

    } catch (e) {
      throw Exception('계정 삭제 중 오류가 발생했습니다: $e');
    }
  }
}
```

## 체크리스트

### 빌드 및 배포

- [ ] 릴리즈 빌드에서 디버그 배너 제거 확인
- [ ] 앱스토어용 스크린샷 재촬영
- [ ] 앱 설명 및 메타데이터 검토

### 인증 기능

- [ ] Sign in with Apple 구현
- [ ] 기존 로그인 방식과 통합
- [ ] 사용자 데이터 처리 로직 구현

### 계정 관리

- [ ] 계정 삭제 기능 구현
- [ ] 확인 다이얼로그 구현
- [ ] 데이터 삭제 로직 구현

### 지원 및 문서

- [ ] 지원 웹페이지 생성
- [ ] App Store Connect URL 업데이트
- [ ] 사용자 가이드 작성

## 예상 소요 시간

- **Phase 1**: 1-2일
- **Phase 2**: 3-5일
- **Phase 3**: 2-3일
- **총 예상 시간**: 6-10일

## 참고 자료

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Sign in with Apple Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
