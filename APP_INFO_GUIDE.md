# 📱 앱 정보 변경 가이드

## ✅ 현재 설정된 정보

### 1. 앱 이름 (사용자에게 보이는 이름)
- **현재 값**: `마법 주문`
- **변경 위치**: `android/app/src/main/AndroidManifest.xml`
- **라인**: 8번

```xml
<application
    android:label="해리포터 마법 주문"  ← 여기 변경
    ...
```

---

### 2. 앱 설명 (프로젝트 설명)
- **현재 값**: `음성으로 마법 주문을 외치는 해리포터 테마 앱`
- **변경 위치**: `pubspec.yaml`
- **라인**: 2번

```yaml
name: namer_app
description: 음성으로 마법 주문을 외치는 해리포터 테마 앱  ← 여기 변경
```

---

### 3. 패키지명/앱 ID (플레이스토어에서 앱을 식별하는 고유 ID)
- **현재 값**: `com.magicspells.app`
- **이전 값**: `com.example.flutter_application_1`
- **변경 위치**: `android/app/build.gradle.kts` (2곳)

#### 위치 1: namespace (9번 라인)
```kotlin
android {
    namespace = "com.magicspells.app"  ← 여기
    ...
}
```

#### 위치 2: applicationId (24번 라인)
```kotlin
defaultConfig {
    applicationId = "com.magicspells.app"  ← 여기
    ...
}
```

---

### 4. MainActivity 패키지 (코드 패키지명)
- **현재 위치**: `android/app/src/main/kotlin/com/magicspells/app/MainActivity.kt`
- **이전 위치**: `android/app/src/main/kotlin/com/example/flutter_application_1/MainActivity.kt`

```kotlin
package com.magicspells.app  ← 패키지명

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

---

### 5. 버전 정보
- **현재 버전**: `1.0.0+1`
- **변경 위치**: `pubspec.yaml`
- **라인**: 6번

```yaml
version: 1.0.0+1
# 형식: 버전이름+빌드번호
# 업데이트 시: 1.0.1+2, 1.1.0+3 등으로 증가
```

---

## 🔄 변경 방법

### 앱 이름 변경하기

1. `android/app/src/main/AndroidManifest.xml` 열기
2. 8번 라인 찾기
3. `android:label="원하는 이름"` 변경

### 앱 설명 변경하기

1. `pubspec.yaml` 열기
2. 2번 라인 `description:` 찾기
3. 설명 변경

### 패키지명(앱 ID) 변경하기

⚠️ **주의**: 플레이스토어 출시 후에는 변경 불가!

#### Step 1: build.gradle.kts 수정
1. `android/app/build.gradle.kts` 열기
2. 9번 라인: `namespace = "새패키지명"` 변경
3. 24번 라인: `applicationId = "새패키지명"` 변경

#### Step 2: MainActivity.kt 패키지 변경
1. 새 폴더 생성: `android/app/src/main/kotlin/com/새회사명/앱명/`
2. MainActivity.kt 이동 또는 생성
3. 파일 내 `package` 선언 변경

#### Step 3: 기존 파일 삭제 (옵션)
- 이전 폴더 구조 삭제 가능

---

## 📋 패키지명 작성 규칙

### 올바른 형식
```
com.회사명.앱명
```

### 예시
- `com.magicspells.app` ✅
- `com.wizardtech.magicspells` ✅
- `com.yourname.magicapp` ✅

### 잘못된 형식
- `com.example.앱명` ❌ (example 사용 불가)
- `magicspells` ❌ (도메인 형식 필요)
- `com.magic-spells.app` ❌ (하이픈 사용 불가)
- `com.매직.app` ❌ (한글 사용 불가)

### 규칙
1. 소문자만 사용
2. 숫자 허용 (숫자로 시작 불가)
3. 언더스코어(_) 허용
4. 하이픈(-), 특수문자 불가
5. 한글/특수문자 불가
6. 최소 2개 부분 필요 (예: com.앱명)
7. 각 부분은 알파벳으로 시작

---

## 🎯 현재 앱 정보 요약

| 항목 | 값 |
|------|-----|
| **앱 이름** | 마법 주문 |
| **앱 설명** | 음성으로 마법 주문을 외치는 해리포터 테마 앱 |
| **패키지명** | com.magicspells.app |
| **버전** | 1.0.0+1 |
| **MainActivity 경로** | com/magicspells/app/MainActivity.kt |

---

## 🚀 변경 후 할 일

### 1. 클린 빌드
```bash
flutter clean
flutter pub get
```

### 2. 빌드 테스트
```bash
# 디버그 빌드
flutter run

# 릴리즈 빌드 (배포 전)
flutter build appbundle --release
```

### 3. 앱 테스트
- [ ] 앱이 정상 실행되는지 확인
- [ ] 앱 이름이 올바르게 표시되는지 확인
- [ ] 모든 기능이 정상 작동하는지 확인

---

## 📝 추가 변경 사항 (선택사항)

### iOS 앱 이름 변경
`ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>마법 주문</string>
```

### 프로젝트 이름 변경
`pubspec.yaml`:
```yaml
name: magic_spells  # 프로젝트 내부 이름 (소문자, 언더스코어)
```

---

## ⚠️ 중요 사항

### 패키지명 변경 시 주의
1. **플레이스토어 출시 전에만 변경 가능**
   - 출시 후 변경하면 새 앱으로 인식됨
   
2. **모든 위치에서 일치시키기**
   - namespace
   - applicationId
   - MainActivity 패키지명
   
3. **클린 빌드 필수**
   - 변경 후 반드시 `flutter clean` 실행

### 백업 권장
- 변경 전 프로젝트 백업
- Git 커밋 후 변경

---

## 🔍 문제 해결

### 빌드 오류 발생 시

**문제**: `package does not exist`
- **원인**: MainActivity 패키지명 불일치
- **해결**: MainActivity.kt의 package 선언 확인

**문제**: `Manifest merger failed`
- **원인**: AndroidManifest.xml 문법 오류
- **해결**: XML 문법 검사

**문제**: `applicationId is not set`
- **원인**: build.gradle.kts 설정 누락
- **해결**: applicationId 확인

### 클린 빌드 방법
```bash
flutter clean
flutter pub get
cd android
./gradlew clean  # Linux/Mac
gradlew.bat clean  # Windows
cd ..
flutter run
```

---

## 📞 도움말

더 자세한 정보는:
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - 전체 배포 가이드
- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) - 출시 체크리스트
- [README.md](README.md) - 프로젝트 개요

---

**마지막 업데이트**: 변경 완료
**현재 패키지명**: com.magicspells.app ✅

