@echo off
echo ================================
echo 마법 주문 앱 릴리즈 빌드
echo ================================
echo.

echo [1/4] 클린 빌드...
call flutter clean

echo.
echo [2/4] 의존성 설치...
call flutter pub get

echo.
echo [3/4] AAB 빌드 중...
call flutter build appbundle --release

echo.
echo [4/4] 빌드 완료!
echo.
echo 생성된 파일: build\app\outputs\bundle\release\app-release.aab
echo.

echo 폴더 열기...
explorer build\app\outputs\bundle\release

echo.
echo 배포 준비 완료! 🎉
pause

