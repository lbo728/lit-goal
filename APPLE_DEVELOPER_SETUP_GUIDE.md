# Apple Developer 계정 설정 및 Xcode 서명 문제 해결 가이드

## 🔧 현재 문제점

1. **Bundle Identifier 문제**: com.example.litGoal → com.litgoal.app로 변경 필요
2. **Apple Developer 계정 통신 실패**: 팀 설정 문제
3. **프로비저닝 프로필 없음**: 앱 ID 등록 필요

## 📋 해결 단계

### 1단계: Apple Developer 계정 확인

#### 1.1 Apple Developer 계정 상태 확인

1. https://developer.apple.com/account/ 접속
2. Apple ID로 로그인
3. 계정 상태 확인:
   - [ ] Apple Developer Program 멤버십 활성화
   - [ ] 팀 ID 확인 (BYUNGWOO LEE)
   - [ ] 인증서 및 프로비저닝 프로필 상태 확인

#### 1.2 팀 설정 확인

1. Xcode → Preferences → Accounts
2. Apple ID 추가/확인
3. 팀 선택 확인

### 2단계: Bundle Identifier 수정

#### 2.1 Xcode에서 Bundle ID 변경

1. Runner 프로젝트 선택
2. Runner 타겟 선택
3. General 탭에서 Bundle Identifier 변경:
   - 기존: com.example.litGoal
   - 변경: com.litgoal.app

#### 2.2 프로젝트 파일에서 확인

```bash
cd ios
grep -r "PRODUCT_BUNDLE_IDENTIFIER" .
```

### 3단계: App ID 등록

#### 3.1 Apple Developer Console에서 App ID 생성

1. https://developer.apple.com/account/resources/identifiers/list 접속
2. "+" 버튼 클릭하여 새 App ID 생성
3. 설정:
   - Description: LitGoal
   - Bundle ID: com.litgoal.app
   - Capabilities: 필요한 기능 선택

#### 3.2 App ID 확인

- App ID가 성공적으로 생성되었는지 확인
- 상태가 "Active"인지 확인

### 4단계: 인증서 및 프로비저닝 프로필 설정

#### 4.1 자동 서명 설정

1. Xcode에서 Runner 프로젝트 선택
2. Signing & Capabilities 탭
3. "Automatically manage signing" 체크박스 선택
4. Team 선택: "BYUNGWOO LEE"
5. Bundle Identifier 확인: com.litgoal.app

#### 4.2 수동 설정 (자동 설정 실패 시)

1. "Automatically manage signing" 체크 해제
2. Provisioning Profile 수동 선택
3. Signing Certificate 확인

### 5단계: 디바이스 등록 (개발용)

#### 5.1 테스트 디바이스 등록

1. Apple Developer Console → Devices
2. "+" 버튼으로 새 디바이스 추가
3. UDID 입력 (Xcode → Window → Devices and Simulators에서 확인)

#### 5.2 프로비저닝 프로필 업데이트

1. Certificates, Identifiers & Profiles → Profiles
2. 해당 App ID의 프로비저닝 프로필 확인
3. 필요한 경우 새로 생성

### 6단계: Xcode 설정 재설정

#### 6.1 Xcode 캐시 정리

```bash
# Xcode 캐시 삭제
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

#### 6.2 프로젝트 클린 빌드

1. Xcode에서 Product → Clean Build Folder
2. Product → Clean

#### 6.3 Xcode 재시작

1. Xcode 완전 종료
2. Xcode 재시작
3. 프로젝트 다시 열기

### 7단계: 앱스토어 배포용 설정

#### 7.1 배포용 인증서 확인

1. Apple Developer Console → Certificates
2. "Apple Distribution" 인증서 확인
3. 없으면 새로 생성

#### 7.2 배포용 프로비저닝 프로필

1. Certificates, Identifiers & Profiles → Profiles
2. App Store 배포용 프로비저닝 프로필 확인
3. 없으면 새로 생성

## 🔍 문제 해결 체크리스트

### Apple Developer 계정

- [ ] Apple Developer Program 멤버십 활성화
- [ ] 팀 ID 확인
- [ ] 인증서 상태 확인

### Xcode 설정

- [ ] Bundle Identifier: com.litgoal.app
- [ ] Team 선택: BYUNGWOO LEE
- [ ] Automatically manage signing 활성화
- [ ] Provisioning Profile 자동 생성 확인

### App ID 등록

- [ ] com.litgoal.app App ID 생성
- [ ] App ID 상태: Active
- [ ] 필요한 Capabilities 설정

### 인증서 및 프로필

- [ ] Apple Development 인증서
- [ ] Apple Distribution 인증서 (배포용)
- [ ] 개발용 프로비저닝 프로필
- [ ] 배포용 프로비저닝 프로필

## 🚨 자주 발생하는 오류 및 해결방법

### 1. "Communication with Apple failed"

**원인**: Apple Developer 계정 연결 문제
**해결방법**:

1. Xcode → Preferences → Accounts 확인
2. Apple ID 재로그인
3. 팀 선택 재확인

### 2. "No profiles for 'com.litgoal.app' were found"

**원인**: App ID 미등록 또는 프로비저닝 프로필 없음
**해결방법**:

1. Apple Developer Console에서 App ID 생성
2. 자동 서명 활성화
3. Xcode에서 프로젝트 새로고침

### 3. "Signing Certificate not found"

**원인**: 인증서 문제
**해결방법**:

1. Apple Developer Console에서 인증서 확인
2. Xcode에서 인증서 다운로드
3. Keychain Access에서 인증서 확인

## 📞 추가 지원

### Apple Developer Support

- https://developer.apple.com/support/
- 기술적 문제 해결 지원

### Xcode 도움말

- Xcode → Help → Xcode Help
- 개발자 문서 참조

### 커뮤니티 지원

- Apple Developer Forums
- Stack Overflow
- GitHub Issues
