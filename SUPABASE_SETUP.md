# Supabase 설정 가이드

## 1. Supabase 프로젝트 설정

1. [Supabase Dashboard](https://supabase.com/dashboard)에 접속
2. 프로젝트: `https://supabase.com/dashboard/project/enyxrgxixrnoazzgqyyd`

## 2. 데이터베이스 테이블 생성

Supabase Dashboard의 SQL Editor에서 다음 SQL을 실행하세요:

```sql
-- Books 테이블 생성
CREATE TABLE books (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  author TEXT,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  target_date TIMESTAMP WITH TIME ZONE NOT NULL,
  image_url TEXT,
  current_page INTEGER DEFAULT 0,
  total_pages INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) 활성화
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 자신의 데이터에 접근할 수 있도록 정책 생성
CREATE POLICY "Allow all operations for authenticated users" ON books
  FOR ALL USING (true);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_books_created_at ON books(created_at DESC);
CREATE INDEX idx_books_start_date ON books(start_date);
CREATE INDEX idx_books_target_date ON books(target_date);

-- 업데이트 시간 자동 갱신을 위한 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
CREATE TRIGGER update_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

## 3. 환경 변수 설정

`.env` 파일에 다음 내용을 추가하세요:

```env
# Supabase 설정
SUPABASE_URL=https://enyxrgxixrnoazzgqyyd.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

**중요**: `SUPABASE_ANON_KEY`는 Supabase Dashboard의 Settings > API에서 확인할 수 있습니다.

## 4. 주요 기능

### 4.1 책 추가

- `reading_start_screen.dart`에서 새로운 독서 정보를 입력
- Supabase의 `books` 테이블에 데이터 저장

### 4.2 책 목록 조회

- `book_list_screen.dart`에서 Supabase에서 책 목록을 불러와 표시
- 실시간으로 데이터 동기화

### 4.3 책 상세 정보

- `book_detail_screen.dart`에서 책의 상세 정보 표시
- 현재 페이지 업데이트 기능

### 4.4 현재 페이지 업데이트

- 책 상세 화면에서 현재 페이지를 탭하여 업데이트
- Supabase에 실시간으로 저장

## 5. 데이터 구조

### books 테이블 스키마

| 컬럼명       | 타입      | 설명                         |
| ------------ | --------- | ---------------------------- |
| id           | UUID      | 기본키 (자동 생성)           |
| title        | TEXT      | 책 제목                      |
| author       | TEXT      | 저자 (선택사항)              |
| start_date   | TIMESTAMP | 독서 시작일                  |
| target_date  | TIMESTAMP | 목표 완독일                  |
| image_url    | TEXT      | 책 이미지 URL (선택사항)     |
| current_page | INTEGER   | 현재 읽은 페이지 (기본값: 0) |
| total_pages  | INTEGER   | 총 페이지 수 (기본값: 0)     |
| created_at   | TIMESTAMP | 생성일시 (자동 생성)         |
| updated_at   | TIMESTAMP | 수정일시 (자동 업데이트)     |

## 6. 보안 설정

현재는 개발 단계로 모든 사용자가 모든 데이터에 접근할 수 있도록 설정되어 있습니다.
실제 배포 시에는 사용자 인증을 추가하고 RLS 정책을 더 세밀하게 설정해야 합니다.
