# 재무제표 시각화 앱

이 프로젝트는 DART OpenAPI를 활용하여 기업의 재무제표를 조회하고 시각화하는 Flutter 애플리케이션입니다.

## 🚀 주요 기능

- **회사 검색**: 회사명으로 회사코드 검색
- **재무제표 조회**: DART API를 통한 재무제표 데이터 수집
- **데이터 시각화**: 매출액, 자산/부채, 수익성 지표 차트
- **환경 변수를 통한 API 키 관리**
- **AI API 연동** (OpenAI, Anthropic, Google)
- **DART OpenAPI 연동** (회사코드 다운로드, 공시검색)
- **CSV 파일 생성 및 저장**

## 📋 설치 및 설정

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. 환경 변수 설정

1. 프로젝트 루트에 `.env` 파일을 생성하세요:

```bash
# Windows
copy env_template.txt .env

# macOS/Linux
cp env_template.txt .env
```

2. `.env` 파일을 열고 실제 API 키로 교체하세요:

```env
# API Keys
OPENAI_API_KEY=sk-your-actual-openai-api-key
ANTHROPIC_API_KEY=sk-ant-your-actual-anthropic-api-key
GOOGLE_API_KEY=your-actual-google-api-key
DART_API_KEY=your-actual-dart-api-key

# API Configuration
API_BASE_URL=https://api.example.com
DART_API_BASE_URL=https://opendart.fss.or.kr/api

# Debug Mode
DEBUG_MODE=true
```

### 3. 회사코드 다운로드 (필수)

앱 사용 전에 회사코드를 다운로드해야 합니다:

```bash
dart run bin/dart_downloader.dart
```

### 4. API 키 획득 방법

#### DART OpenAPI (필수)
1. [DART OpenAPI](https://opendart.fss.or.kr/) 사이트 방문
2. 회원가입 및 로그인
3. API 키 신청 및 발급
4. 발급받은 키를 `DART_API_KEY`에 설정

#### OpenAI API (선택)
1. [OpenAI Platform](https://platform.openai.com/) 방문
2. 계정 생성 및 API 키 발급
3. 발급받은 키를 `OPENAI_API_KEY`에 설정

#### Anthropic API (선택)
1. [Anthropic Console](https://console.anthropic.com/) 방문
2. 계정 생성 및 API 키 발급
3. 발급받은 키를 `ANTHROPIC_API_KEY`에 설정

#### Google API (선택)
1. [Google Cloud Console](https://console.cloud.google.com/) 방문
2. 프로젝트 생성 및 API 키 발급
3. 발급받은 키를 `GOOGLE_API_KEY`에 설정

## 🔧 프로젝트 구조

```
lib/
├── config/
│   └── env_config.dart                    # 환경 변수 관리 클래스
├── services/
│   ├── api_service.dart                   # AI API 서비스
│   ├── dart_api_service.dart              # DART API 서비스
│   ├── financial_statement_service.dart   # 재무제표 API 서비스
│   └── company_code_service.dart          # 회사코드 검색 서비스
├── widgets/
│   └── financial_charts.dart              # 재무제표 차트 위젯
└── main.dart                              # 메인 애플리케이션
bin/
└── dart_downloader.dart                   # 회사코드 다운로드 도구
```

## 🚀 실행 방법

### Flutter 앱 실행
```bash
flutter run
```

### 회사코드 다운로드 (명령줄)
```bash
dart run bin/dart_downloader.dart
```

### 회사코드 다운로드 (옵션 포함)
```bash
dart run bin/dart_downloader.dart --corp-cls Y --start-date 20240101 --end-date 20241231
```

## 📱 사용법

### 앱 사용 순서

1. **회사코드 다운로드**: DART API 탭에서 회사코드 다운로드
2. **회사 검색**: 재무제표 시각화 탭에서 회사명 입력 후 검색
3. **회사 선택**: 검색 결과에서 원하는 회사 선택
4. **재무제표 조회**: 사업연도 입력 후 재무제표 조회
5. **시각화 확인**: 차트와 테이블로 재무제표 분석

### 주요 화면

#### 1. AI API 테스트 탭
- OpenAI, Anthropic, Google API 테스트
- 프롬프트 입력 및 응답 확인

#### 2. DART API 탭
- 공시검색 기능
- 회사코드 다운로드 기능
- 검색 결과 CSV 저장

#### 3. 재무제표 시각화 탭
- **회사 검색**: 회사명으로 회사 검색
- **재무제표 조회**: 선택된 회사의 재무제표 데이터 조회
- **시각화**: 
  - 재무제표 요약 테이블
  - 매출액 추이 차트 (막대 차트)
  - 자산/부채 비교 차트 (선 차트)
  - 수익성 지표 차트 (선 차트)

## 📊 차트 종류

### 1. 매출액 추이 차트
- 연도별 매출액 변화를 막대 차트로 표시
- 매출액, 매출 관련 계정과목 포함

### 2. 자산/부채 비교 차트
- 자산총계와 부채총계를 선 차트로 비교
- 녹색: 자산, 빨간색: 부채

### 3. 수익성 지표 차트
- 당기순이익과 영업이익을 선 차트로 표시
- 파란색: 당기순이익, 주황색: 영업이익

### 4. 재무제표 요약 테이블
- 주요 계정과목별 당기/전기 비교
- 매출액, 영업이익, 당기순이익, 자산총계, 부채총계, 자본총계

## 🛡️ 보안 주의사항

### ✅ 올바른 방법
- `.env` 파일을 `.gitignore`에 포함
- 실제 API 키는 절대 Git에 커밋하지 않음
- 프로덕션 환경에서는 환경 변수 사용

### ❌ 잘못된 방법
- API 키를 코드에 하드코딩
- `.env` 파일을 Git에 커밋
- API 키를 로그에 출력

## ⚠️ 주의사항

1. **회사코드 파일**: 앱 실행 전 반드시 `corpCodes.json` 파일이 필요합니다.
2. **API 키**: DART API 키는 필수이며, 다른 API 키들은 선택사항입니다.
3. **데이터 제한**: DART API는 일일 요청 한도가 있으므로 과도한 요청을 피해주세요.
4. **재무제표 데이터**: 모든 회사가 재무제표를 공시하지 않을 수 있습니다.

## 🔍 환경 변수 확인

앱 실행 시 콘솔에서 환경 변수 상태를 확인할 수 있습니다:

```
=== 환경 변수 목록 ===
OPENAI_API_KEY: 설정됨
ANTHROPIC_API_KEY: 설정됨
GOOGLE_API_KEY: 설정됨
DART_API_KEY: 설정됨
API_BASE_URL: https://api.example.com
DART_API_BASE_URL: https://opendart.fss.or.kr/api
DEBUG_MODE: true
```

## 🛠️ 개발 환경 설정

### VS Code 설정

`.vscode/settings.json` 파일을 생성하여 다음 설정을 추가하세요:

```json
{
  "dart.envFile": ".env",
  "dart.flutterSdkPath": "path/to/flutter"
}
```

### IntelliJ IDEA 설정

1. Run/Debug Configurations에서 Environment variables 추가
2. `.env` 파일 경로 설정

## 📚 추가 리소스

- [Dart dotenv 패키지](https://pub.dev/packages/dotenv)
- [Flutter Charts](https://pub.dev/packages/fl_chart)
- [DART OpenAPI](https://opendart.fss.or.kr/)
- [OpenAI API 문서](https://platform.openai.com/docs)
- [Anthropic API 문서](https://docs.anthropic.com/)
- [Google API 문서](https://developers.google.com/apis-explorer)

## 🤝 기여하기

1. 이 저장소를 포크하세요
2. 새로운 브랜치를 생성하세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## ⚠️ 면책 조항

이 프로젝트는 교육 목적으로만 제공됩니다. 실제 프로덕션 환경에서 사용하기 전에 적절한 보안 검토를 수행하세요.
