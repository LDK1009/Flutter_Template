# 🪄 마법 주문 앱 배포 가이드

## 📋 목차
1. [사전 준비](#1-사전-준비)
2. [앱 ID 변경](#2-앱-id-변경)
3. [서명 키 생성](#3-서명-키-생성)
4. [서명 설정](#4-서명-설정)
5. [릴리즈 빌드](#5-릴리즈-빌드)
6. [구글 플레이 콘솔 설정](#6-구글-플레이-콘솔-설정)
7. [앱 업로드](#7-앱-업로드)

---

## 1. 사전 준비

### 필요한 것들
- ✅ Google Play Console 개발자 계정 (25달러 일회성 등록비)
- ✅ 앱 아이콘 (512x512 PNG)
- ✅ 앱 스크린샷 (최소 2장)
- ✅ 개인정보처리방침 URL (필수)

### 현재 앱 정보
- **앱 이름**: 마법 주문
- **패키지명**: `com.example.flutter_application_1` (변경 필요!)
- **버전**: 0.0.1+1

---

## 2. 앱 ID 변경

### 2.1 고유한 패키지명으로 변경

**현재**: `com.example.flutter_application_1`  
**권장**: `com.yourcompany.magicspells` (예: `com.wizardtech.magicspells`)

#### 변경 방법:

**파일 1**: `android/app/build.gradle.kts`
```kotlin
defaultConfig {
    applicationId = "com.yourcompany.magicspells"  // 여기 변경
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = 1
    versionName = "1.0.0"
}
```

**파일 2**: `android/app/build.gradle.kts` 상단
```kotlin
android {
    namespace = "com.yourcompany.magicspells"  // 여기도 변경
    ...
}
```

**파일 3**: `android/app/src/main/kotlin/` 폴더 구조 변경
```
android/app/src/main/kotlin/com/example/flutter_application_1/MainActivity.kt
→
android/app/src/main/kotlin/com/yourcompany/magicspells/MainActivity.kt
```

**MainActivity.kt** 파일 내용도 변경:
```kotlin
package com.yourcompany.magicspells  // 변경

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
```

---

## 3. 서명 키 생성

### 3.1 키스토어 생성

터미널에서 실행:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**입력 사항:**
- 비밀번호 입력 (2번)
- 이름
- 조직 단위
- 조직
- 시/도
- 국가 코드 (KR)

⚠️ **중요**: 생성된 `upload-keystore.jks` 파일과 비밀번호를 안전하게 보관하세요!

### 3.2 키 정보 저장

Windows:
```bash
C:\Users\YourUser\upload-keystore.jks
```

생성된 키를 프로젝트 외부에 안전하게 보관하세요.

---

## 4. 서명 설정

### 4.1 key.properties 파일 생성

`android/key.properties` 파일 생성:

```properties
storePassword=여기에_스토어_비밀번호
keyPassword=여기에_키_비밀번호
keyAlias=upload
storeFile=C:/Users/YourUser/upload-keystore.jks
```

⚠️ **중요**: `.gitignore`에 `android/key.properties` 추가!

### 4.2 build.gradle.kts 수정

`android/app/build.gradle.kts` 파일 수정:

```kotlin
// 파일 상단에 추가
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    // signingConfigs 추가 (buildTypes 위에)
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release  // 변경
        }
    }
}
```

**Kotlin DSL 버전**의 경우:

`android/app/build.gradle.kts`:

```kotlin
// 파일 최상단에 추가
import java.util.Properties
import java.io.FileInputStream

// keystoreProperties 로드
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## 5. 릴리즈 빌드

### 5.1 버전 업데이트

`pubspec.yaml`:
```yaml
version: 1.0.0+1
# 형식: 버전이름+빌드번호
# 예: 1.0.0+1, 1.0.1+2, 1.1.0+3
```

### 5.2 AAB(Android App Bundle) 빌드

```bash
flutter clean
flutter build appbundle --release
```

빌드 성공 시 생성 위치:
```
build/app/outputs/bundle/release/app-release.aab
```

### 5.3 APK 빌드 (선택사항, 테스트용)

```bash
flutter build apk --release
```

생성 위치:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 6. 구글 플레이 콘솔 설정

### 6.1 개발자 계정 생성

1. [Google Play Console](https://play.google.com/console) 접속
2. 계정 만들기 ($25 일회성 등록비 결제)
3. 약관 동의

### 6.2 새 앱 만들기

1. **모든 앱** → **앱 만들기**
2. 정보 입력:
   - 앱 이름: `마법 주문`
   - 기본 언어: `한국어`
   - 앱/게임: `앱`
   - 무료/유료: `무료`

### 6.3 앱 정보 설정

#### a) 스토어 등록정보

**앱 이름**
```
마법 주문
```

**간단한 설명** (80자 이하)
```
음성으로 마법 주문을 외쳐보세요! 플래시 제어와 마법 효과음 포함
```

**전체 설명**
```
🪄 마법 주문 앱에 오신 것을 환영합니다!

해리포터의 마법사가 되어보세요! 음성 인식으로 마법 주문을 외치면 실제로 마법이 작동합니다.

✨ 주요 기능:
- 🔦 루모스: 플래시 켜기
- 🌙 녹스: 플래시 끄기  
- 🎵 실제 마법 효과음
- 📖 마법 주문서 포함
- 🏰 호그와트 테마

📚 포함된 주문:
- 루모스 (빛을 밝히는 주문)
- 녹스 (빛을 끄는 주문)
- 윙가르디움 레비오우사 (물체를 띄우는 주문)
- 알로호모라 (잠금 해제 주문)
- 그 외 다양한 주문들!

음성 인식으로 간편하게 주문을 외치고, 마법사의 세계를 경험하세요!
```

**앱 아이콘** (512x512 PNG)
- 투명 배경 없는 PNG
- 정사각형 512x512px

**스크린샷**
- 최소 2장, 최대 8장
- 휴대전화: 320px ~ 3840px (16:9 권장)

#### b) 앱 카테고리

- **카테고리**: 엔터테인먼트
- **태그**: 마법, 음성인식, 효과음

#### c) 연락처 세부정보

- 이메일 주소
- 전화번호 (선택)
- 웹사이트 (선택)

#### d) 개인정보처리방침

⚠️ **필수**: 개인정보처리방침 URL이 필요합니다.

**간단한 샘플**:
```
이 앱은 다음 권한을 사용합니다:
- 마이크: 음성 인식을 위해 사용됩니다
- 카메라/플래시: 플래시 제어를 위해 사용됩니다

수집된 음성 데이터는 기기 내에서만 처리되며 서버로 전송되지 않습니다.
```

개인정보처리방침 생성 도구:
- [App Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/)
- [PrivacyPolicies.com](https://www.privacypolicies.com/)

### 6.4 콘텐츠 등급

1. **콘텐츠 등급** 설정
2. 설문조사 완료 (폭력성, 성적 콘텐츠 등)
3. 마법 주문 앱은 대부분 **전체 이용가** 가능

### 6.5 앱 콘텐츠

- **대상 연령**: 전체 연령
- **광고 포함 여부**: 아니요 (광고 없으면)
- **인앱 결제**: 아니요 (결제 없으면)

---

## 7. 앱 업로드

### 7.1 프로덕션 트랙 생성

1. **출시** → **프로덕션**
2. **새 출시 만들기**

### 7.2 AAB 업로드

1. **Android App Bundle** 업로드
2. 파일 선택: `app-release.aab`

### 7.3 출시 정보 입력

**출시 이름**
```
버전 1.0.0 - 첫 출시
```

**출시 노트** (한국어)
```
🎉 마법 주문 앱 첫 출시!

✨ 주요 기능:
- 음성으로 마법 주문 실행
- 루모스/녹스 주문으로 플래시 제어
- 다양한 마법 효과음
- 아름다운 호그와트 테마
```

### 7.4 검토 제출

1. 모든 설정 완료 확인
2. **검토를 위해 제출**
3. 구글 검토 대기 (보통 1~3일)

---

## 8. 업데이트 배포

### 버전 업데이트 시

1. `pubspec.yaml` 버전 증가:
```yaml
version: 1.0.1+2  # 버전이름+빌드번호
```

2. 빌드:
```bash
flutter build appbundle --release
```

3. 플레이 콘솔에서 새 출시 만들기

---

## 🔧 문제 해결

### 빌드 에러

**문제**: `Signing config not found`
- **해결**: `key.properties` 파일 경로 확인

**문제**: Gradle 버전 오류
- **해결**: Android Studio에서 Gradle 업데이트

### 검토 거부

**흔한 이유**:
1. 개인정보처리방침 누락
2. 스크린샷 부족
3. 앱 설명 불충분
4. 위험 권한 설명 부족

**해결**:
- 마이크/카메라 권한 사용 이유 명확히 설명
- 스크린샷 추가
- 개인정보처리방침 작성

---

## 📝 체크리스트

배포 전 확인사항:

- [ ] 앱 ID 변경 완료
- [ ] 서명 키 생성 및 보관
- [ ] key.properties 설정
- [ ] 버전 정보 확인
- [ ] AAB 빌드 성공
- [ ] 앱 아이콘 준비 (512x512)
- [ ] 스크린샷 준비 (최소 2장)
- [ ] 개인정보처리방침 URL 준비
- [ ] 앱 설명 작성
- [ ] 출시 노트 작성
- [ ] Google Play Console 계정 생성
- [ ] 검토 제출

---

## 🚀 빠른 배포 명령어

```bash
# 1. 클린 빌드
flutter clean

# 2. 의존성 설치
flutter pub get

# 3. AAB 빌드
flutter build appbundle --release

# 4. 빌드 파일 확인
# Windows
explorer build\app\outputs\bundle\release

# macOS/Linux
open build/app/outputs/bundle/release
```

---

## 📞 추가 도움말

- [Flutter 공식 배포 가이드](https://docs.flutter.dev/deployment/android)
- [Google Play Console 도움말](https://support.google.com/googleplay/android-developer)
- [Android 서명 가이드](https://developer.android.com/studio/publish/app-signing)

---

## 💡 팁

1. **첫 배포는 시간이 걸립니다**
   - 구글 검토: 1~3일
   - 완벽하게 준비하세요

2. **키스토어 백업**
   - 키를 잃어버리면 앱 업데이트 불가!
   - 안전한 곳에 백업

3. **베타 테스트**
   - 프로덕션 전에 내부/비공개 테스트 권장
   - 친구들에게 먼저 테스트

4. **스토어 최적화 (ASO)**
   - 좋은 아이콘과 스크린샷
   - 키워드가 포함된 설명
   - 사용자 리뷰 관리

행운을 빕니다! 🪄✨

