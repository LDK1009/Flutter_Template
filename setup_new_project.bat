REM ============================================
REM Flutter 새 프로젝트 자동 세팅 스크립트
REM ============================================

@echo off
REM 명령어 코드를 화면에 표시하지 않음 (출력만 보임)

chcp 65001 >nul
REM UTF-8 인코딩 설정 (한글과 이모지 표시용), >nul로 설정 메시지 숨김

echo ============================================
echo Flutter 새 프로젝트 세팅 스크립트
echo ============================================
echo.
REM echo. = 빈 줄 출력

REM ============================================
REM 1단계: 기존 키스토어 파일 삭제
REM ============================================
echo [1/5] 기존 키스토어 파일 삭제 중...

if exist "android\app\upload-keystore.jks" (
    REM 파일이 존재하면 삭제 (/f=강제삭제, /q=확인안함)
    del /f /q "android\app\upload-keystore.jks"
    echo   ✓ upload-keystore.jks 삭제 완료
) else (
    REM 파일이 없으면 메시지만 출력
    echo   - upload-keystore.jks 파일이 없습니다
)

if exist "android\key.properties" (
    REM key.properties 파일도 삭제
    del /f /q "android\key.properties"
    echo   ✓ key.properties 삭제 완료
) else (
    echo   - key.properties 파일이 없습니다
)
echo.

REM ============================================
REM 2단계: 사용자 입력 받기
REM ============================================
echo [2/5] 새 프로젝트 정보 입력
echo.

REM set /p 변수명="프롬프트" : 사용자 입력을 변수에 저장
set /p APP_NAME="앱 이름을 입력하세요 (예: 해리포터 마법 주문): "
set /p APP_ID="Application ID를 입력하세요 (예: com.appname.app): "
set /p PROJECT_NAME="프로젝트 코드명을 입력하세요 (예: harrypotter_magic_spells): "
set /p APP_DESC="앱 설명을 입력하세요: "
set /p KEYSTORE_PASSWORD="키스토어 비밀번호를 입력하세요: "
echo.

REM ============================================
REM 3단계: 새 키스토어 생성
REM ============================================
echo [3/5] 새 키스토어 생성 중...

cd android\app
REM android\app 디렉토리로 이동 (키스토어 저장 위치)

echo.
echo 다음 정보를 입력하세요:
echo (엔터를 눌러 건너뛰기 가능)

REM keytool: Java 키스토어 생성 도구
REM -genkey: 키 생성, -v: 상세정보 표시, -keystore: 파일명
REM -keyalg RSA: RSA 알고리즘, -keysize 2048: 키 크기
REM -validity 10000: 10000일 유효, -alias upload: 별칭
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass "%KEYSTORE_PASSWORD%" -keypass "%KEYSTORE_PASSWORD%"

cd ..\..
REM 원래 디렉토리로 돌아가기 (프로젝트 루트)

echo   ✓ 키스토어 생성 완료
echo.

REM ============================================
REM 4단계: key.properties 생성
REM ============================================
echo [4/5] key.properties 파일 생성 중...

REM ( ... ) > 파일명 : 괄호 안의 내용을 파일로 저장
(
echo # 키스토어 비밀번호
echo storePassword=%KEYSTORE_PASSWORD%
echo # 키 비밀번호
echo keyPassword=%KEYSTORE_PASSWORD%
echo keyAlias=upload
echo storeFile=upload-keystore.jks
) > android\key.properties
REM key.properties 파일 생성 완료

echo   ✓ key.properties 생성 완료
echo.

REM ============================================
REM 5단계: 프로젝트 파일 수정
REM ============================================
echo [5/5] 프로젝트 파일 수정 중...

REM -------- build.gradle.kts 수정 --------
REM PowerShell을 이용해 파일 내용 치환 (정규식 사용)
REM Get-Content: 파일 읽기, -replace: 치환, Set-Content: 파일 쓰기

REM namespace 수정 (Android 패키지명)
powershell -Command "(Get-Content 'android\app\build.gradle.kts') -replace 'namespace = \".*?\" // 🔄 새 프로젝트 생성 시 수정 \(예: com\.company\.appname\)', 'namespace = \"%APP_ID%\" // 🔄 새 프로젝트 생성 시 수정 (예: com.company.appname)' | Set-Content 'android\app\build.gradle.kts'"

REM applicationId 수정 (앱 고유 식별자)
powershell -Command "(Get-Content 'android\app\build.gradle.kts') -replace 'applicationId = \".*?\" // 🔄 새 프로젝트 생성 시 수정 \(예: com\.company\.appname\)', 'applicationId = \"%APP_ID%\" // 🔄 새 프로젝트 생성 시 수정 (예: com.company.appname)' | Set-Content 'android\app\build.gradle.kts'"

REM versionCode 수정 (앱 버전 코드, 숫자)
powershell -Command "(Get-Content 'android\app\build.gradle.kts') -replace 'versionCode = \d+ // 🔄 새 프로젝트 생성 시 수정 \(1로 시작\)', 'versionCode = 1 // 🔄 새 프로젝트 생성 시 수정 (1로 시작)' | Set-Content 'android\app\build.gradle.kts'"

REM versionName 수정 (앱 버전 이름, 문자열)
powershell -Command "(Get-Content 'android\app\build.gradle.kts') -replace 'versionName = \".*?\" // 🔄 새 프로젝트 생성 시 수정 \(1\.0\.0으로 시작\)', 'versionName = \"1.0.0\" // 🔄 새 프로젝트 생성 시 수정 (1.0.0으로 시작)' | Set-Content 'android\app\build.gradle.kts'"

echo   ✓ build.gradle.kts 수정 완료

REM -------- AndroidManifest.xml 수정 --------
REM 앱 이름(레이블) 수정
powershell -Command "(Get-Content 'android\app\src\main\AndroidManifest.xml') -replace 'android:label=\".*?\" // 🔄 새 프로젝트 생성 시 수정 \(앱 이름\)', 'android:label=\"%APP_NAME%\" // 🔄 새 프로젝트 생성 시 수정 (앱 이름)' | Set-Content 'android\app\src\main\AndroidManifest.xml'"
echo   ✓ AndroidManifest.xml 수정 완료

REM -------- pubspec.yaml 수정 --------
REM 프로젝트 이름 수정 (^는 줄 시작을 의미)
powershell -Command "(Get-Content 'pubspec.yaml') -replace '^name: .*? # 🔄 새 프로젝트 생성 시 수정 \(프로젝트 코드명\)', 'name: %PROJECT_NAME% # 🔄 새 프로젝트 생성 시 수정 (프로젝트 코드명)' | Set-Content 'pubspec.yaml'"

REM 앱 설명 수정
powershell -Command "(Get-Content 'pubspec.yaml') -replace '^description: .*? # 🔄 새 프로젝트 생성 시 수정', 'description: %APP_DESC% # 🔄 새 프로젝트 생성 시 수정' | Set-Content 'pubspec.yaml'"

REM 버전 수정 (1.0.0+1 형식: 버전명+빌드번호)
powershell -Command "(Get-Content 'pubspec.yaml') -replace '^version: .*? # 🔄 새 프로젝트 생성 시 수정 \(1\.0\.0\+1로 시작\)', 'version: 1.0.0+1 # 🔄 새 프로젝트 생성 시 수정 (1.0.0+1로 시작)' | Set-Content 'pubspec.yaml'"

echo   ✓ pubspec.yaml 수정 완료

REM ============================================
REM 완료 메시지 출력
REM ============================================
echo.
echo ============================================
echo ✅ 새 프로젝트 세팅 완료!
echo ============================================
echo.

REM 설정된 내용 요약 출력
echo 📋 설정된 내용:
echo   - 앱 이름: %APP_NAME%
echo   - Application ID: %APP_ID%
echo   - 프로젝트 코드명: %PROJECT_NAME%
echo   - 버전: 1.0.0+1
echo.

REM 생성된 보안 파일 안내
echo 🔒 보안 파일 생성:
echo   - android/app/upload-keystore.jks
echo   - android/key.properties
echo.

REM 수동으로 해야 할 작업 안내
echo ⚠️  다음 작업을 직접 수행하세요:
echo   1. 앱 아이콘 변경 (android/app/src/main/res/mipmap-*)
echo   2. flutter clean 실행
echo   3. flutter pub get 실행
echo   4. flutter build appbundle --release 테스트
echo.

REM 키스토어 백업 경고
echo 💾 키스토어 파일을 반드시 안전한 곳에 백업하세요!
echo.

pause
REM pause: 사용자가 키를 누를 때까지 대기 (창이 자동으로 닫히지 않음)

