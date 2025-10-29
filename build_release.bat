REM ============================================
REM Flutter 릴리즈 빌드 자동화 스크립트
REM - 버전 코드 자동 증가
REM - 빌드 실행
REM ============================================

@echo off
REM 명령어 코드를 화면에 표시하지 않음

chcp 65001 >nul
REM UTF-8 인코딩 설정

echo ============================================
echo 마법 주문 앱 릴리즈 빌드
echo ============================================
echo.

REM ============================================
REM 1단계: 버전 코드 자동 증가
REM ============================================
echo [1/5] 버전 코드 자동 증가 중...

REM PowerShell로 pubspec.yaml에서 현재 버전 읽기
for /f "tokens=*" %%i in ('powershell -Command "(Get-Content 'pubspec.yaml' | Select-String 'version:').ToString().Split('+')[1].Trim().Split(' ')[0]"') do set CURRENT_BUILD=%%i
echo   현재 빌드 번호: %CURRENT_BUILD%

REM 빌드 번호 1 증가
set /a NEW_BUILD=%CURRENT_BUILD%+1
echo   새 빌드 번호: %NEW_BUILD%

REM 버전명 읽기 (예: 1.0.0)
for /f "tokens=*" %%i in ('powershell -Command "(Get-Content 'pubspec.yaml' | Select-String 'version:').ToString().Split(':')[1].Trim().Split('+')[0].Trim()"') do set VERSION_NAME=%%i
echo   버전명: %VERSION_NAME%

REM pubspec.yaml 업데이트 (UTF-8 인코딩으로 저장)
powershell -Command "$content = Get-Content 'pubspec.yaml' -Encoding UTF8; $content -replace 'version: .*? # 🔄', 'version: %VERSION_NAME%+%NEW_BUILD% # 🔄' | Set-Content 'pubspec.yaml' -Encoding UTF8"

REM build.gradle.kts 업데이트 (UTF-8 인코딩으로 저장)
powershell -Command "$content = Get-Content 'android\app\build.gradle.kts' -Encoding UTF8; $content -replace 'versionCode = \d+ // 🔄', 'versionCode = %NEW_BUILD% // 🔄' | Set-Content 'android\app\build.gradle.kts' -Encoding UTF8"
powershell -Command "$content = Get-Content 'android\app\build.gradle.kts' -Encoding UTF8; $content -replace 'versionName = \".*?\" // 🔄', 'versionName = \"%VERSION_NAME%\" // 🔄' | Set-Content 'android\app\build.gradle.kts' -Encoding UTF8"

echo   ✓ 버전 업데이트 완료: %VERSION_NAME%+%NEW_BUILD%
echo.

REM ============================================
REM 2단계: 클린 빌드
REM ============================================
echo [2/5] 클린 빌드...
call flutter clean
echo.

REM ============================================
REM 3단계: 의존성 설치
REM ============================================
echo [3/5] 의존성 설치...
call flutter pub get
echo.

REM ============================================
REM 4단계: AAB 빌드
REM ============================================
echo [4/5] AAB 빌드 중...
call flutter build appbundle --release
echo.

REM ============================================
REM 5단계: 완료
REM ============================================
echo [5/5] 빌드 완료!
echo.
echo ============================================
echo ✅ 릴리즈 빌드 완료!
echo ============================================
echo.
echo 📦 생성된 파일:
echo   build\app\outputs\bundle\release\app-release.aab
echo.
echo 📋 버전 정보:
echo   버전명: %VERSION_NAME%
echo   빌드 번호: %NEW_BUILD%
echo.
echo 💡 다음 단계:
echo   1. Google Play Console에 로그인
echo   2. 앱 선택 → 프로덕션 → 새 버전 만들기
echo   3. app-release.aab 파일 업로드
echo.

REM 빌드 폴더 열기
echo 빌드 폴더 열기...
explorer build\app\outputs\bundle\release

echo.
echo 배포 준비 완료! 🎉
echo.
pause
