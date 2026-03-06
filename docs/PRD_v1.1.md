# PRD: Guild Board

> **버전**: v1.1
> **작성일**: 2026-03-06
> **기반 보일러플레이트**: [ror-hatchling](https://github.com/luisjang1206/ror-hatchling) (Rails 8.1 + PostgreSQL 17)

---

## 1. 제품 개요

### 1.1 목적

AI 코딩 에이전트의 작업 현황을 실시간으로 추적하고, 사람과 에이전트가 동일한 칸반 보드에서 협업하는 웹 서비스.

### 1.2 제품명: Guild Board

길드(Guild) — 중세 장인 조합에서 유래한 이름. 사람과 AI 에이전트가 하나의 길드에 소속되어 공동의 프로젝트를 수행한다는 컨셉을 담고 있다.

### 1.3 핵심 가치

- **가시성**: 에이전트가 무엇을 하고 있는지 한눈에 파악
- **협업**: 사람이 태스크를 등록하면 에이전트가 수행하고, 진행 상황을 보드에 반영
- **실시간**: 에이전트의 액션이 새로고침 없이 즉시 화면에 반영
- **영속성**: 모든 데이터는 DB에 저장되어 유실되지 않음

### 1.4 사용 시나리오

1. 사용자가 "로그인 페이지 구현" 태스크를 Backlog에 등록
2. 사용자가 해당 태스크를 Todo로 이동
3. 에이전트에게 작업 지시 → 에이전트가 MCP `move_task`로 In Progress로 이동
4. 에이전트가 작업하면서 `add_comment`로 "컴포넌트 구조 설계 완료", "API 연동 중" 등 기록
5. 에이전트가 체크리스트 항목을 하나씩 체크
6. 완료 후 에이전트가 `move_task`로 Review로 이동 + 코멘트에 결과 요약
7. 사용자가 리뷰 후 Done으로 이동

---

## 2. 전제 조건

### 2.1 프로젝트 생성 완료 상태

아래 작업이 이미 완료된 상태에서 Guild Board 고유 기능 구현을 시작한다.

```bash
# 보일러플레이트로 프로젝트 생성
git clone https://github.com/luisjang1206/ror-hatchling.git
rails new guild_board -d postgresql -c tailwind -m ror-hatchling/template.rb

# DB 및 앱 기동
cd guild_board
docker-compose up db -d
bin/setup
bin/dev
```

### 2.2 사용 가능한 보일러플레이트 기능

| 기능                                                                                                        | 상태      |
| ----------------------------------------------------------------------------------------------------------- | --------- |
| Rails 8 authentication (로그인/로그아웃/회원가입/비밀번호 재설정)                                           | 동작 중   |
| Pundit 정책 기반 권한 관리 + User role enum (user/admin/super_admin)                                        | 동작 중   |
| ViewComponent 10종 (Button, Card, Badge, Flash, Modal, Dropdown, FormField, EmptyState, Pagination, Navbar) | 동작 중   |
| Stimulus 컨트롤러 4종 (flash, modal, dropdown, navbar)                                                      | 동작 중   |
| Admin 패널 (Admin 네임스페이스, 별도 레이아웃, 역할 기반 접근 제어)                                         | 동작 중   |
| SolidQueue (백그라운드 잡)                                                                                  | 동작 중   |
| SolidCache (캐시, Rate Limit 백엔드)                                                                        | 동작 중   |
| SolidCable (Action Cable WebSocket)                                                                         | 동작 중   |
| Hotwire (Turbo + Stimulus) + Tailwind CSS v4                                                                | 동작 중   |
| Pagy (페이지네이션) + Lograge (구조화 로그)                                                                 | 동작 중   |
| Kamal 2 + GitHub Actions CI/CD                                                                              | 설정 완료 |
| Multi-DB (primary/cache/queue/cable) on PostgreSQL 17                                                       | 동작 중   |

### 2.3 확인 사항

- `http://localhost:3000` 접속 시 기본 앱 정상 표시
- 회원가입/로그인 플로우 정상 동작
- Admin 페이지 (`/admin`) 접근 가능 (admin 역할 계정)
- `bin/rails test` 전체 통과

---

## 3. 기능 요구사항

### 3.1 프로젝트 관리

| 항목              | 설명                                                            |
| ----------------- | --------------------------------------------------------------- |
| **프로젝트 CRUD** | 사용자가 여러 프로젝트를 생성/수정/삭제                         |
| **프로젝트 키**   | 프로젝트 생성 시 고유 API 키 자동 발급 (예: `guild_a1b2c3d4e5`) |
| **키 관리**       | 프로젝트 설정에서 키 조회, 재발급, 비활성화, 복수 키 발급 가능  |
| **키별 권한**     | 키마다 허용할 MCP 도구를 개별 설정 (읽기 전용, 생성/이동만 등)  |
| **연결 모니터링** | 현재 키로 연결된 에이전트 목록, 연결 로그 확인                  |

### 3.2 보드 & 칼럼 관리

| 항목                  | 설명                                                                               |
| --------------------- | ---------------------------------------------------------------------------------- |
| **기본 칼럼**         | 프로젝트 생성 시 기본 5개 칼럼 자동 생성: Backlog, Todo, In Progress, Review, Done |
| **칼럼 커스터마이징** | 칼럼 추가, 삭제, 이름 변경, 순서 변경                                              |
| **칼럼 정렬**         | 드래그앤드롭으로 칼럼 순서 조정                                                    |

### 3.3 태스크(카드) 관리

| 항목             | 설명                                                                           |
| ---------------- | ------------------------------------------------------------------------------ |
| **태스크 CRUD**  | 제목, 설명, 우선순위, 라벨 설정                                                |
| **드래그앤드롭** | 카드를 칼럼 간 드래그하여 상태 변경                                            |
| **우선순위**     | High / Medium / Low (3단계)                                                    |
| **라벨/태그**    | 프로젝트별 라벨 정의, 태스크에 복수 라벨 부착 (예: frontend, bugfix, refactor) |
| **체크리스트**   | 태스크 내 하위 항목 목록, 완료 체크, 진행률 표시                               |
| **코멘트**       | 사람/에이전트 모두 코멘트 작성 가능                                            |
| **생성자 구분**  | 사람이 만든 카드인지, 에이전트가 만든 카드인지 시각적 구분                     |
| **소프트 삭제**  | 태스크 삭제 시 실제 삭제가 아닌 플래그 처리, 복구 가능                         |

### 3.4 MCP 서버 (에이전트 연동)

프로젝트 키 기반으로 에이전트가 보드를 직접 조작할 수 있는 MCP(Model Context Protocol) 서버를 제공한다.

#### 3.4.1 연결 방식

에이전트는 MCP 설정에 프로젝트 키와 에이전트 이름을 포함하여 연결한다:

```json
{
  "type": "url",
  "url": "https://guildboard.example.com/mcp",
  "name": "guild-board",
  "headers": {
    "X-Project-Key": "guild_a1b2c3d4e5",
    "X-Agent-Name": "claude-frontend"
  }
}
```

- 프로젝트 키로 어떤 프로젝트인지 자동 판별
- 에이전트 이름으로 활동 로그에서 어떤 에이전트의 액션인지 식별
- 같은 키로 여러 에이전트 세션이 동시에 연결 가능

#### 3.4.2 MCP 도구 목록

| 도구                 | 설명                         | 주요 파라미터                                                                   |
| -------------------- | ---------------------------- | ------------------------------------------------------------------------------- |
| **list_tasks**       | 현재 보드의 전체 태스크 조회 | `column` (선택), `label` (선택), `priority` (선택)                              |
| **get_task**         | 특정 태스크 상세 조회        | `task_id`                                                                       |
| **create_task**      | 새 태스크 생성               | `title`, `description` (선택), `column` (선택, 기본 Backlog), `priority` (선택) |
| **update_task**      | 태스크 정보 수정             | `task_id`, `title` (선택), `description` (선택), `priority` (선택)              |
| **move_task**        | 태스크를 다른 칼럼으로 이동  | `task_id`, `column` (칼럼명 또는 ID)                                            |
| **add_comment**      | 태스크에 코멘트 추가         | `task_id`, `content`                                                            |
| **update_checklist** | 체크리스트 항목 체크/언체크  | `task_id`, `checklist_item_id`, `completed`                                     |
| **list_columns**     | 현재 보드의 칼럼 목록 조회   | 없음                                                                            |

#### 3.4.3 인증 & 권한

- 프로젝트 키가 유효하지 않거나 비활성 상태이면 연결 거부
- 키별 권한 설정에 따라 허용되지 않은 도구 호출 시 에러 반환
- 모든 MCP 요청은 활동 로그에 기록

### 3.5 실시간 업데이트

| 항목                  | 설명                                                        |
| --------------------- | ----------------------------------------------------------- |
| **기술**              | Action Cable (SolidCable + PostgreSQL) + Turbo Streams      |
| **브로드캐스트 대상** | 태스크 생성, 이동, 수정, 삭제, 코멘트 추가, 체크리스트 변경 |
| **채널 구조**         | 프로젝트별 채널 (`BoardChannel` with project_id)            |
| **적용 범위**         | 웹 UI에서 보드를 보고 있는 모든 사용자에게 즉시 반영        |

### 3.6 활동 타임라인

| 항목          | 설명                                                         |
| ------------- | ------------------------------------------------------------ |
| **기록 범위** | 모든 태스크 변경 이력 (생성, 이동, 수정, 코멘트, 체크리스트) |
| **액터 구분** | 사람/에이전트를 아이콘/색상으로 시각 구분                    |
| **뷰 레벨**   | 카드별 타임라인 + 보드 전체 타임라인                         |
| **저장 방식** | append-only (수정/삭제 없음, 완전한 이력 보존)               |

### 3.7 필터 & 뷰

| 필터            | 설명                   |
| --------------- | ---------------------- |
| **담당자 타입** | 사람 / 에이전트 / 전체 |
| **라벨**        | 복수 라벨 선택 필터링  |
| **우선순위**    | High / Medium / Low    |
| **칼럼(상태)**  | 특정 칼럼만 표시       |

---

## 4. 데이터 모델

### 4.1 엔티티 관계도

```
Users (보일러플레이트 기존 모델)
 └── has_many :projects

Projects
 ├── has_many :project_keys
 ├── has_many :columns
 ├── has_many :tasks
 ├── has_many :labels
 └── has_many :activity_logs

ProjectKeys
 └── belongs_to :project

Columns
 ├── belongs_to :project
 └── has_many :tasks

Tasks
 ├── belongs_to :project
 ├── belongs_to :column
 ├── has_many :checklists
 ├── has_many :comments
 ├── has_many :task_labels → Labels
 └── has_many :activity_logs

Labels
 ├── belongs_to :project
 └── has_many :task_labels → Tasks

Checklists
 └── belongs_to :task

Comments
 └── belongs_to :task

ActivityLogs
 ├── belongs_to :project
 └── belongs_to :task (optional)
```

### 4.2 테이블 정의

#### projects

| 칼럼        | 타입        | 설명        |
| ----------- | ----------- | ----------- |
| id          | bigint (PK) |             |
| user_id     | bigint (FK) | 소유자      |
| name        | string      | 프로젝트명  |
| description | text        | 설명 (선택) |
| created_at  | datetime    |             |
| updated_at  | datetime    |             |

#### project_keys

| 칼럼         | 타입        | 설명                                  |
| ------------ | ----------- | ------------------------------------- |
| id           | bigint (PK) |                                       |
| project_id   | bigint (FK) |                                       |
| key_digest   | string      | 키 해시값 (bcrypt 또는 SHA256)        |
| key_prefix   | string      | 키 앞 8자 (UI 식별용, 예: `guild_a1`) |
| name         | string      | 키 이름 (예: "claude-frontend용")     |
| permissions  | jsonb       | 허용 도구 목록 (기본: 전체 허용)      |
| active       | boolean     | 활성 여부 (기본: true)                |
| last_used_at | datetime    | 마지막 사용 시각                      |
| created_at   | datetime    |                                       |

#### columns

| 칼럼       | 타입        | 설명      |
| ---------- | ----------- | --------- |
| id         | bigint (PK) |           |
| project_id | bigint (FK) |           |
| name       | string      | 칼럼명    |
| position   | integer     | 정렬 순서 |
| created_at | datetime    |           |
| updated_at | datetime    |           |

#### tasks

| 칼럼         | 타입        | 설명                              |
| ------------ | ----------- | --------------------------------- |
| id           | bigint (PK) |                                   |
| project_id   | bigint (FK) |                                   |
| column_id    | bigint (FK) | 현재 위치 칼럼                    |
| title        | string      | 제목                              |
| description  | text        | 설명                              |
| priority     | integer     | enum (0: low, 1: medium, 2: high) |
| position     | integer     | 칼럼 내 정렬 순서                 |
| creator_type | string      | "user" 또는 "agent"               |
| creator_id   | string      | user_id 또는 agent_name           |
| deleted_at   | datetime    | 소프트 삭제 (null이면 활성)       |
| created_at   | datetime    |                                   |
| updated_at   | datetime    |                                   |

#### labels

| 칼럼       | 타입        | 설명                    |
| ---------- | ----------- | ----------------------- |
| id         | bigint (PK) |                         |
| project_id | bigint (FK) |                         |
| name       | string      | 라벨명                  |
| color      | string      | 색상 코드 (예: #FF5733) |
| created_at | datetime    |                         |

#### task_labels

| 칼럼     | 타입        | 설명 |
| -------- | ----------- | ---- |
| task_id  | bigint (FK) |      |
| label_id | bigint (FK) |      |

> 복합 PK (task_id, label_id)

#### checklists

| 칼럼       | 타입        | 설명                    |
| ---------- | ----------- | ----------------------- |
| id         | bigint (PK) |                         |
| task_id    | bigint (FK) |                         |
| content    | string      | 항목 내용               |
| completed  | boolean     | 완료 여부 (기본: false) |
| position   | integer     | 정렬 순서               |
| created_at | datetime    |                         |
| updated_at | datetime    |                         |

#### comments

| 칼럼        | 타입        | 설명                    |
| ----------- | ----------- | ----------------------- |
| id          | bigint (PK) |                         |
| task_id     | bigint (FK) |                         |
| author_type | string      | "user" 또는 "agent"     |
| author_id   | string      | user_id 또는 agent_name |
| content     | text        | 코멘트 내용             |
| created_at  | datetime    |                         |

#### activity_logs

| 칼럼       | 타입                  | 설명                                                     |
| ---------- | --------------------- | -------------------------------------------------------- |
| id         | bigint (PK)           |                                                          |
| project_id | bigint (FK)           |                                                          |
| task_id    | bigint (FK, nullable) |                                                          |
| actor_type | string                | "user" 또는 "agent"                                      |
| actor_id   | string                | user_id 또는 agent_name                                  |
| action     | string                | "created", "moved", "updated", "commented", "checked" 등 |
| changes    | jsonb                 | 변경 내용 (예: `{"column": ["Todo", "In Progress"]}`)    |
| created_at | datetime              |                                                          |

> append-only 테이블, updated_at 없음

---

## 5. 보일러플레이트 활용 계획

### 5.1 그대로 활용 (변경 없음)

| 보일러플레이트 기능       | Guild Board에서의 역할                            |
| ------------------------- | ------------------------------------------------- |
| Rails 8 authentication    | 사용자 로그인/로그아웃/회원가입                   |
| Pundit                    | 프로젝트/태스크 접근 제어, MCP 키 권한 관리       |
| SolidCable (Action Cable) | 에이전트 액션 실시간 브로드캐스트                 |
| SolidQueue                | 활동 로그 비동기 기록, 알림 처리                  |
| SolidCache                | Rate Limit 백엔드 (MCP 요청 제한)                 |
| ViewComponent 10종        | Button, Card, Modal, Flash, Badge 등 칸반 UI 기반 |
| Stimulus 4종              | Flash, Modal, Dropdown, Navbar 컨트롤러           |
| Tailwind CSS v4           | 전체 스타일링                                     |
| Pagy                      | 활동 로그, 태스크 목록 페이지네이션               |
| Lograge                   | 구조화된 운영 로그                                |
| Admin 패널                | 전체 서비스 관리 (사용자 관리, 프로젝트 현황)     |
| Kamal 2 + CI/CD           | 배포 파이프라인                                   |

### 5.2 확장하여 활용

| 보일러플레이트 기능   | 확장 내용                           |
| --------------------- | ----------------------------------- |
| User 모델 (role enum) | 프로젝트 소유자 관계 추가           |
| Admin 네임스페이스    | 전체 프로젝트/키 관리 대시보드 추가 |
| ApplicationController | MCP 인증용 concern 추가             |
| Rate Limit            | MCP 엔드포인트에 rate_limit 적용    |

### 5.3 새로 구현

| 영역                   | 구현 항목                                                                                                                   |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **도메인 모델**        | 8개 테이블 마이그레이션 (4.2절 참조)                                                                                        |
| **컨트롤러**           | ProjectsController, BoardsController, TasksController, Api::McpController                                                   |
| **MCP 서버**           | SSE 엔드포인트, 프로젝트 키 인증, 8개 도구 구현                                                                             |
| **Action Cable 채널**  | BoardChannel (프로젝트별 실시간 브로드캐스트)                                                                               |
| **Turbo Streams**      | 태스크 생성/이동/수정/삭제 실시간 DOM 업데이트                                                                              |
| **Stimulus 컨트롤러**  | drag_controller (드래그앤드롭), filter_controller (필터), board_controller (보드 상태)                                      |
| **ViewComponent 추가** | KanbanColumnComponent, TaskCardComponent, ActivityLogComponent, ProjectKeyComponent, FilterBarComponent, ChecklistComponent |
| **Pundit 정책**        | ProjectPolicy, TaskPolicy, ProjectKeyPolicy                                                                                 |

### 5.4 젬 추가 정책

보일러플레이트의 "외부 젬 최소화" 철학을 유지한다. 추가 젬이 필요한 경우 아래 기준으로 판단한다:

| 후보 젬            | 용도                    | 판단                                                |
| ------------------ | ----------------------- | --------------------------------------------------- |
| acts_as_list       | position 칼럼 자동 관리 | 검토 필요 — Rails 기본 기능으로 대체 가능 여부 확인 |
| mcp-rb (또는 유사) | MCP 프로토콜 서버 구현  | 검토 필요 — 프로토콜 복잡도에 따라 결정             |

> 원칙: 직접 구현이 합리적이면 젬 추가하지 않는다.

---

## 6. 아키텍처

### 6.1 전체 구조

```
[사용자 브라우저]
    │
    ├── Turbo + Stimulus (칸반 UI, 드래그앤드롭)
    │         ↕ Turbo Streams via WebSocket
    │
[Guild Board Rails 앱] ←── Action Cable (SolidCable / PostgreSQL)
    │
    ├── 웹 컨트롤러 (Projects, Boards, Tasks)
    ├── Api::Mcp 컨트롤러 (MCP 프로토콜 엔드포인트)
    │         ↑
    │    X-Project-Key 인증
    │         ↑
[AI 에이전트 (Claude, Cursor 등)]
    │
    └── MCP 클라이언트 → SSE 연결
         → list_tasks, create_task, move_task, add_comment...
```

### 6.2 MCP 요청 흐름

```
1. 에이전트가 Guild Board MCP 서버에 SSE 연결 (X-Project-Key 헤더 포함)
2. Rails가 키를 검증 → 프로젝트 식별 → 권한 확인
3. 에이전트가 도구 호출 (예: move_task)
4. Rails가 태스크 상태 변경 → DB 저장
5. 활동 로그 기록 (SolidQueue 비동기)
6. Action Cable로 BoardChannel에 브로드캐스트
7. 사용자 브라우저에 Turbo Stream으로 카드 이동 반영
```

### 6.3 프로젝트 키 인증 흐름

```
1. 요청 수신 → X-Project-Key 헤더 추출
2. key_prefix 추출 (앞 8자) → project_keys 테이블에서 후보 조회
3. key_digest와 전체 키 비교 (bcrypt verify)
4. active == true 확인
5. permissions JSON에서 요청된 도구 허용 여부 확인
6. last_used_at 갱신
7. 인증 실패 시 401/403 반환
```

---

## 7. 라우트 구조

```ruby
# 웹 UI
resources :projects do
  resource :board, only: [:show]
  resources :columns, only: [:create, :update, :destroy] do
    member do
      patch :move  # 칼럼 순서 변경
    end
  end
  resources :tasks do
    resources :comments, only: [:create]
    resources :checklists, only: [:create, :update, :destroy]
    member do
      patch :move  # 칼럼 간 이동
    end
  end
  resources :labels, only: [:index, :create, :update, :destroy]
  resources :project_keys, only: [:index, :create, :destroy] do
    member do
      patch :regenerate
      patch :toggle_active
    end
  end
  resources :activity_logs, only: [:index]
end

# MCP 엔드포인트
namespace :api do
  namespace :mcp do
    get :sse       # SSE 연결
    post :messages # MCP 메시지 수신
  end
end

# Admin 확장 (기존 admin 네임스페이스 활용)
namespace :admin do
  resources :projects, only: [:index, :show]
  resources :project_keys, only: [:index]
end
```

---

## 8. 구현 단계 (Phases)

> **전제**: 보일러플레이트(ror-hatchling)로 프로젝트 생성, DB 설정, `bin/setup` 완료 상태에서 시작한다. (2절 참조)

### Phase 1: 도메인 모델 & 기본 CRUD

- 8개 테이블 마이그레이션 생성 및 실행
- 모델 정의 (관계, 유효성 검증, enum, 소프트 삭제)
- Pundit 정책 (ProjectPolicy, TaskPolicy, ProjectKeyPolicy)
- 프로젝트 CRUD (웹 UI)
- 프로젝트 키 관리 (생성, 조회, 비활성화, 재발급)

### Phase 2: 칸반 보드 UI

- 보드 뷰 (칼럼별 태스크 렌더링)
- ViewComponent 추가 (KanbanColumn, TaskCard, FilterBar, Checklist 등)
- 태스크 CRUD (생성, 수정, 삭제)
- 드래그앤드롭 Stimulus 컨트롤러
- 칼럼 관리 (추가, 삭제, 이름 변경, 순서 변경)
- 라벨 관리
- 체크리스트 관리
- 코멘트
- 필터링

### Phase 3: 실시간 업데이트

- BoardChannel (Action Cable)
- Turbo Streams 브로드캐스트 (태스크 생성/이동/수정/삭제/코멘트)
- 웹 UI에서 실시간 반영 확인

### Phase 4: MCP 서버

- MCP SSE 엔드포인트 구현
- 프로젝트 키 인증 미들웨어
- 8개 MCP 도구 구현
- MCP 요청 → DB 변경 → Action Cable 브로드캐스트 연동
- Rate Limit 적용

### Phase 5: 활동 타임라인 & 고도화

- 활동 로그 기록 (모든 변경 사항)
- 활동 타임라인 뷰 (보드 전체 + 카드별)
- 사람/에이전트 액터 시각 구분
- Admin 패널 확장 (프로젝트 현황, 키 관리)

### Phase 6: 테스트 & 배포

- 모델/컨트롤러 단위 테스트
- MCP 도구 통합 테스트
- 시스템 테스트 (Capybara)
- CI 파이프라인에 새 테스트 포함
- Kamal 2 배포 설정 업데이트

---

## 9. 향후 확장 고려사항 (Out of Scope)

아래 항목은 v1 범위에 포함하지 않으며, 필요 시 후속 버전에서 추가한다.

| 항목                      | 설명                                                               |
| ------------------------- | ------------------------------------------------------------------ |
| 멀티 유저 협업            | 프로젝트에 여러 사용자 초대, 역할별 권한                           |
| 알림 시스템               | 에이전트 액션(Review 요청 등) 시 사용자 알림 (이메일, 브라우저 등) |
| 멀티 에이전트 식별 고도화 | 에이전트별 아바타, 통계, 성과 대시보드                             |
| 에이전트 권한 세분화      | 도구별을 넘어 칼럼별, 라벨별 세부 권한                             |
| 보드 템플릿               | 자주 사용하는 보드 구조를 템플릿으로 저장/불러오기                 |
| 타임 트래킹               | 태스크별 소요 시간 기록 및 리포트                                  |
| 외부 연동                 | GitHub Issues, Linear, Jira 등과 양방향 동기화                     |
| 모바일 대응               | 반응형 UI 또는 전용 모바일 뷰                                      |
