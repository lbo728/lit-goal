# AdMob 실제 광고 연결 가이드

## 1. Google AdMob 계정 생성 및 설정

### 1.1 AdMob 계정 생성

1. https://admob.google.com 접속
2. Google 계정으로 로그인
3. 국가/지역 선택: **대한민국**
4. 결제 정보 입력 (개인 또는 사업자)
5. 약관 동의 후 계정 생성

### 1.2 앱 등록

1. AdMob 대시보드에서 **"앱 추가"** 클릭
2. 플랫폼 선택: **Android** 및 **iOS**
3. 앱 정보 입력:
   - 앱 이름: **"LitGoal"**
   - 패키지명: `com.example.lit_goal`
   - 앱 스토어 링크 (출시 후 추가)

## 2. 광고 단위 생성

### 2.1 배너 광고 단위 생성

1. 등록된 앱에서 **"광고 단위 추가"** 클릭
2. 광고 형식: **"배너"** 선택
3. 광고 단위 이름: **"LitGoal_Banner"**
4. 생성 완료 후 **광고 단위 ID** 복사

### 2.2 전면 광고 단위 생성

1. **"광고 단위 추가"** 클릭
2. 광고 형식: **"전면"** 선택
3. 광고 단위 이름: **"LitGoal_Interstitial"**
4. 생성 완료 후 **광고 단위 ID** 복사

## 3. 코드에 실제 광고 ID 적용

### 3.1 AdMob 설정 파일 수정

`lib/config/admob_config.dart` 파일에서 다음 값들을 교체:

```dart
class AdMobConfig {
  // 개발 모드 여부 (릴리즈 시 false로 변경)
  static const bool isDevelopmentMode = false; // ← 이 값을 false로 변경

  // 실제 광고 단위 ID (AdMob에서 생성한 ID로 교체)
  static const String _androidBannerAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_BANNER_AD_UNIT_ID';
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_INTERSTITIAL_AD_UNIT_ID';

  static const String _iosBannerAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_BANNER_AD_UNIT_ID';
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_INTERSTITIAL_AD_UNIT_ID';

  // AdMob 앱 ID (AndroidManifest.xml과 Info.plist에서 사용)
  static const String androidAppId = 'ca-app-pub-YOUR_PUBLISHER_ID~YOUR_ANDROID_APP_ID';
  static const String iosAppId = 'ca-app-pub-YOUR_PUBLISHER_ID~YOUR_IOS_APP_ID';
}
```

### 3.2 Android 설정 업데이트

`android/app/src/main/AndroidManifest.xml` 파일에서:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_PUBLISHER_ID~YOUR_ANDROID_APP_ID"/>
```

### 3.3 iOS 설정 업데이트

`ios/Runner/Info.plist` 파일에서:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_PUBLISHER_ID~YOUR_IOS_APP_ID</string>
```

## 4. 광고 ID 찾는 방법

### 4.1 AdMob 대시보드에서 확인

1. AdMob 대시보드 → **"앱"** 탭
2. 등록한 앱 선택
3. **"광고 단위"** 탭에서 각 광고 단위의 ID 확인
4. **"앱 설정"**에서 앱 ID 확인

### 4.2 광고 단위 ID 형식

- 앱 ID: `ca-app-pub-1234567890123456~1234567890`
- 광고 단위 ID: `ca-app-pub-1234567890123456/1234567890`

## 5. 테스트 및 검증

### 5.1 테스트 단계

1. **개발 모드 (isDevelopmentMode = true)**에서 테스트 광고 확인
2. **실제 광고 모드 (isDevelopmentMode = false)**로 전환
3. 실제 기기에서 광고 표시 확인

### 5.2 주의사항

- **개발 중에는 절대 실제 광고를 클릭하지 마세요** (계정 정지 위험)
- 테스트 기기를 AdMob에 등록하여 안전하게 테스트
- 앱 출시 전에 충분한 테스트 진행

## 6. 앱 출시 준비

### 6.1 출시 전 체크리스트

- [ ] 실제 광고 단위 ID 적용 완료
- [ ] `isDevelopmentMode = false` 설정
- [ ] Android/iOS 앱 ID 설정 완료
- [ ] 실제 기기에서 광고 표시 확인
- [ ] AdMob 정책 준수 확인

### 6.2 앱 스토어 등록 후

1. Google Play Store / App Store에 앱 등록
2. AdMob 대시보드에서 앱 스토어 링크 연결
3. 앱 검토 및 승인 대기

## 7. 수익 확인 및 최적화

### 7.1 수익 확인

- AdMob 대시보드에서 실시간 수익 확인
- 월 $100 이상 수익 시 결제 진행

### 7.2 광고 최적화

- 광고 배치 최적화
- 사용자 경험과 수익의 균형 유지
- A/B 테스트를 통한 성과 개선

## 문제 해결

### 자주 발생하는 문제

1. **광고가 표시되지 않음**: 광고 단위 ID 확인, 네트워크 연결 확인
2. **앱이 크래시됨**: 앱 ID 설정 확인, SDK 초기화 확인
3. **수익이 발생하지 않음**: 실제 사용자 트래픽 필요, 정책 위반 확인

### 지원 및 문의

- AdMob 고객 지원: https://support.google.com/admob
- 개발자 문서: https://developers.google.com/admob
