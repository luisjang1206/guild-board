# TSD: Guild Board — Tech Stack Definition

> **버전**: v1.0
> **작성일**: 2026-03-06
> **관련 문서**: [PRD v1.1](./PRD-v1.1.md)
> **기반 보일러플레이트**: [ror-hatchling](https://github.com/luisjang1206/ror-hatchling) (TSD-v1.3 기준)

---

## 1. 문서 목적

Guild Board 프로젝트의 기술 스택을 정의한다. 보일러플레이트(ror-hatchling)에서 계승하는 기술과 Guild Board에서 새로 도입하는 기술을 명확히 구분하고, 각각의 버전 핀과 채택 근거를 기록한다.

---

## 2. 기술 스택 총괄표

### 2.1 보일러플레이트 계승 (변경 없음)

ror-hatchling TSD-v1.3에서 정의된 버전을 그대로 사용한다.

| 레이어              | 기술                         | 버전                                      | 비고                               |
| ------------------- | ---------------------------- | ----------------------------------------- | ---------------------------------- |
| **Language**        | Ruby (MRI)                   | ~> 3.4                                    | mise로 관리                        |
| **Framework**       | Ruby on Rails                | ~> 8.1                                    | Full-stack                         |
| **Database**        | PostgreSQL                   | 17.x                                      | Docker 컨테이너, ~2029-11 EOL      |
| **Frontend**        | Hotwire (Turbo + Stimulus)   | turbo-rails ~> 2.0, stimulus-rails ~> 1.3 |                                    |
| **CSS**             | Tailwind CSS v4              | tailwindcss-rails ~> 4.2                  | Standalone Rust CLI                |
| **Asset Pipeline**  | Propshaft + Import Maps      | propshaft ~> 1.1, importmap-rails ~> 2.1  | Node.js 불필요                     |
| **Background Jobs** | SolidQueue                   | ~> 1.3                                    | PostgreSQL 기반                    |
| **Cache**           | SolidCache                   | ~> 1.0                                    | PostgreSQL 기반, Rate Limit 백엔드 |
| **WebSocket**       | SolidCable                   | ~> 3.0                                    | PostgreSQL 기반 Action Cable       |
| **Authentication**  | bcrypt (has_secure_password) | ~> 3.1                                    | Rails 8 auth generator             |
| **Deployment**      | Kamal 2                      | ~> 2.10                                   | kamal-proxy (Rust)                 |
| **Web Server**      | Puma (behind Thruster)       | puma ~> 6.5, thruster ~> 0.1              |                                    |
| **CI/CD**           | GitHub Actions               | —                                         | 7-step pipeline                    |
| **Container**       | Docker                       | multi-stage build                         | ruby:3.4-slim base                 |

### 2.2 보일러플레이트 계승 외부 젬 (4개, 변경 없음)

| 젬                 | 버전    | 역할                | Guild Board 활용                            |
| ------------------ | ------- | ------------------- | ------------------------------------------- |
| **pundit**         | ~> 2.5  | 정책 기반 권한 관리 | ProjectPolicy, TaskPolicy, ProjectKeyPolicy |
| **pagy**           | ~> 43.0 | 페이지네이션        | 활동 로그, 태스크 목록                      |
| **lograge**        | ~> 0.14 | 구조화된 JSON 로깅  | MCP 요청 로깅 포함                          |
| **view_component** | ~> 4.4  | UI 컴포넌트         | 기존 10종 + 신규 6종                        |

### 2.3 Guild Board 신규 도입

| 레이어          | 기술       | 버전    | 역할                        | 채택 근거                                                                                 |
| --------------- | ---------- | ------- | --------------------------- | ----------------------------------------------------------------------------------------- |
| **MCP Server**  | fast-mcp   | ~> 1.5  | MCP 프로토콜 서버 구현      | Rails Rack 미들웨어 통합, SSE + Streamable HTTP 지원, Rails generator 제공, 커뮤니티 검증 |
| **Drag & Drop** | SortableJS | ~> 1.15 | 칸반 카드/칼럼 드래그앤드롭 | Import Maps 호환, 프레임워크 비의존, 가볍고 성숙한 라이브러리                             |

> **젬 추가 총계**: 보일러플레이트 4개 + Guild Board 1개 = **5개**

---

## 3. 신규 기술 상세

### 3.1 fast-mcp (MCP 서버)

#### 채택 배경

Guild Board의 핵심 기능인 "AI 에이전트가 MCP를 통해 칸반 보드를 조작"하려면 Rails 앱 자체가 MCP 서버 역할을 해야 한다. MCP 프로토콜을 직접 구현하는 것은 JSON-RPC 2.0 파싱, SSE/Streamable HTTP 트랜스포트, 세션 관리 등 상당한 작업량이 필요하므로, 검증된 젬을 사용한다.

#### 후보 비교

| 젬                      | 버전   | 장점                                                                                                             | 단점                                                | 판정                        |
| ----------------------- | ------ | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | --------------------------- |
| **fast-mcp**            | ~> 1.5 | Rails Rack 미들웨어 통합, generator 제공, Dry-Schema 기반 인자 검증, SSE + Streamable HTTP 지원, 활발한 유지보수 | 외부 의존성 추가 (dry-schema 등)                    | **채택**                    |
| **mcp** (공식 Ruby SDK) | ~> 0.6 | Anthropic 공식, 스펙 준수 보장                                                                                   | 아직 0.x (불안정), Rails 통합 미흡, 주로 stdio 중심 | 보류 — 1.0 안정화 후 재검토 |
| 직접 구현               | —      | 의존성 없음                                                                                                      | 프로토콜 복잡도 높음, 유지보수 부담                 | 기각                        |

#### 통합 방식

```ruby
# Gemfile
gem "fast-mcp", "~> 1.5"

# 설치
bundle add fast-mcp
bin/rails generate fast_mcp:install
```

설치 후 생성되는 구조:

```
app/
├── tools/                    # MCP 도구 정의
│   ├── application_tool.rb
│   ├── list_tasks_tool.rb
│   ├── get_task_tool.rb
│   ├── create_task_tool.rb
│   ├── update_task_tool.rb
│   ├── move_task_tool.rb
│   ├── add_comment_tool.rb
│   ├── update_checklist_tool.rb
│   └── list_columns_tool.rb
├── resources/                # MCP 리소스 정의
│   └── application_resource.rb
config/
└── initializers/
    └── fast_mcp.rb           # MCP 서버 설정
```

#### MCP 프로토콜 스펙 대응

| MCP 스펙               | 버전       | 지원 여부                           |
| ---------------------- | ---------- | ----------------------------------- |
| Streamable HTTP (권장) | 2025-03-26 | fast-mcp 지원                       |
| SSE (레거시 호환)      | 2024-11-05 | fast-mcp 지원                       |
| Structured Tool Output | 2025-06-18 | fast-mcp 지원                       |
| OAuth 2.1              | 2025-06-18 | 미사용 — 프로젝트 키 인증 방식 채택 |

#### 커스텀 인증 레이어

fast-mcp의 기본 인증 대신, Guild Board 고유의 프로젝트 키 기반 인증을 구현한다:

```ruby
# config/initializers/fast_mcp.rb
FastMcp.mount_in_rails(
  Rails.application,
  name: "guild-board",
  version: "1.0.0",
  path_prefix: "/mcp",
  allowed_origins: ENV.fetch("MCP_ALLOWED_ORIGINS", "*").split(",")
) do |server|
  # 프로젝트 키 인증은 커스텀 미들웨어에서 처리
  # before_action에서 X-Project-Key 헤더 검증 후
  # Current.project에 프로젝트 바인딩
  server.register_tools(*ApplicationTool.descendants)
end
```

### 3.2 SortableJS (드래그앤드롭)

#### 채택 배경

칸반 보드의 핵심 UX인 카드 드래그앤드롭을 구현해야 한다. HTML5 Drag API를 직접 사용할 수 있지만, 터치 지원, 애니메이션, 그룹 간 이동 등 고려사항이 많아 전문 라이브러리를 사용한다.

#### 후보 비교

| 라이브러리               | 장점                                                                              | 단점                                                         | 판정     |
| ------------------------ | --------------------------------------------------------------------------------- | ------------------------------------------------------------ | -------- |
| **SortableJS**           | Import Maps 호환, 프레임워크 비의존, 경량(~10KB gzip), 터치 지원, 성숙한 프로젝트 | —                                                            | **채택** |
| HTML5 Drag API 직접 구현 | 의존성 없음                                                                       | 터치 미지원, 애니메이션 직접 구현 필요, 크로스 브라우저 이슈 | 기각     |
| @shopify/draggable       | Shopify 검증                                                                      | Import Maps 호환성 미확인, 과도한 기능                       | 기각     |

#### 통합 방식

```ruby
# config/importmap.rb
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.6/Sortable.min.js"
```

```javascript
// app/javascript/controllers/drag_controller.js
import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  // Stimulus 컨트롤러로 SortableJS 래핑
  // 카드 이동 시 PATCH /projects/:id/tasks/:id/move 호출
}
```

> **참고**: SortableJS는 젬이 아닌 JS 라이브러리이므로 Import Maps로 CDN에서 로드한다. 젬 카운트에 포함되지 않는다.

---

## 4. 데이터베이스 구성

### 4.1 Multi-DB 구조 (보일러플레이트 계승)

보일러플레이트의 4개 논리 DB 구조를 그대로 사용하며, Guild Board 도메인 테이블은 모두 primary DB에 생성한다.

| 논리 DB     | 역할       | 마이그레이션 경로   | Guild Board 용도                    |
| ----------- | ---------- | ------------------- | ----------------------------------- |
| **primary** | 앱 데이터  | `db/migrate/`       | 기존 User/Session + 신규 8개 테이블 |
| **queue**   | SolidQueue | `db/queue_migrate/` | 활동 로그 비동기 기록 잡            |
| **cache**   | SolidCache | `db/cache_migrate/` | Rate Limit, MCP 응답 캐시           |
| **cable**   | SolidCable | `db/cable_migrate/` | BoardChannel 실시간 브로드캐스트    |

### 4.2 신규 테이블 (primary DB)

PRD 4.2절에 정의된 8개 테이블을 `db/migrate/`에 생성한다:

| 테이블        | 주요 인덱스                                                      |
| ------------- | ---------------------------------------------------------------- |
| projects      | `user_id`                                                        |
| project_keys  | `project_id`, `key_prefix` (unique), `active`                    |
| columns       | `project_id`, `[project_id, position]`                           |
| tasks         | `project_id`, `column_id`, `[column_id, position]`, `deleted_at` |
| labels        | `project_id`                                                     |
| task_labels   | `[task_id, label_id]` (unique)                                   |
| checklists    | `task_id`, `[task_id, position]`                                 |
| comments      | `task_id`                                                        |
| activity_logs | `project_id`, `task_id`, `created_at`                            |

### 4.3 PostgreSQL 고유 기능 활용

| 기능            | 용도                                                |
| --------------- | --------------------------------------------------- |
| **jsonb**       | `project_keys.permissions`, `activity_logs.changes` |
| **GIN 인덱스**  | `project_keys.permissions` jsonb 검색 최적화        |
| **부분 인덱스** | `tasks WHERE deleted_at IS NULL` (소프트 삭제 필터) |

---

## 5. 실시간 통신 스택

### 5.1 Action Cable + SolidCable (보일러플레이트 계승)

Redis 없이 PostgreSQL만으로 WebSocket 통신을 처리한다.

```
[에이전트 MCP 요청]
    → [Rails 앱] → DB 변경 저장
                 → Action Cable 브로드캐스트 (SolidCable/PostgreSQL)
                 → [사용자 브라우저] Turbo Stream으로 DOM 업데이트
```

### 5.2 Turbo Streams (보일러플레이트 계승)

| 액션            | Turbo Stream 동작                                         |
| --------------- | --------------------------------------------------------- |
| 태스크 생성     | `turbo_stream.append` — 해당 칼럼에 카드 추가             |
| 태스크 이동     | `turbo_stream.remove` + `turbo_stream.append` — 카드 이동 |
| 태스크 수정     | `turbo_stream.replace` — 카드 내용 갱신                   |
| 태스크 삭제     | `turbo_stream.remove` — 카드 제거                         |
| 코멘트 추가     | `turbo_stream.append` — 코멘트 목록에 추가                |
| 체크리스트 변경 | `turbo_stream.replace` — 체크리스트 영역 갱신             |

---

## 6. 프론트엔드 구성

### 6.1 JavaScript (Import Maps, 보일러플레이트 계승)

Node.js 빌드 도구 없이 Import Maps로 JS 의존성을 관리한다.

```ruby
# config/importmap.rb (Guild Board 추가분)
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.6/Sortable.min.js"
```

### 6.2 Stimulus 컨트롤러

| 컨트롤러                 | 출처           | 역할                                         |
| ------------------------ | -------------- | -------------------------------------------- |
| flash_controller         | 보일러플레이트 | Flash 메시지 자동 닫기                       |
| modal_controller         | 보일러플레이트 | 모달 열기/닫기                               |
| dropdown_controller      | 보일러플레이트 | 드롭다운 토글                                |
| navbar_controller        | 보일러플레이트 | 반응형 네비게이션                            |
| **drag_controller**      | **신규**       | SortableJS 래핑, 카드/칼럼 드래그앤드롭      |
| **filter_controller**    | **신규**       | 필터 UI 상태 관리, Turbo Frame으로 필터 적용 |
| **board_controller**     | **신규**       | 보드 전체 상태 관리, Action Cable 구독       |
| **clipboard_controller** | **신규**       | 프로젝트 키 복사                             |
| **checklist_controller** | **신규**       | 체크리스트 인라인 추가/토글                  |

### 6.3 ViewComponent

| 컴포넌트                  | 출처           | 역할                                      |
| ------------------------- | -------------- | ----------------------------------------- |
| ButtonComponent           | 보일러플레이트 | 버튼, 링크 버튼                           |
| CardComponent             | 보일러플레이트 | 콘텐츠 컨테이너                           |
| BadgeComponent            | 보일러플레이트 | 상태 표시 태그                            |
| FlashComponent            | 보일러플레이트 | 알림 메시지                               |
| ModalComponent            | 보일러플레이트 | 확인/입력 다이얼로그                      |
| DropdownComponent         | 보일러플레이트 | 메뉴, 옵션                                |
| FormFieldComponent        | 보일러플레이트 | 폼 필드 번들                              |
| EmptyStateComponent       | 보일러플레이트 | 빈 데이터 안내                            |
| PaginationComponent       | 보일러플레이트 | Pagy 페이지네이션                         |
| NavbarComponent           | 보일러플레이트 | 네비게이션 바                             |
| **KanbanColumnComponent** | **신규**       | 칸반 칼럼 컨테이너                        |
| **TaskCardComponent**     | **신규**       | 태스크 카드 (우선순위, 라벨, 진행률 표시) |
| **ActivityLogComponent**  | **신규**       | 활동 로그 항목 (사람/에이전트 구분)       |
| **ProjectKeyComponent**   | **신규**       | 프로젝트 키 표시/복사 UI                  |
| **FilterBarComponent**    | **신규**       | 필터 바 (담당자, 라벨, 우선순위)          |
| **ChecklistComponent**    | **신규**       | 체크리스트 위젯 (진행률 바 포함)          |

---

## 7. 테스트 스택 (보일러플레이트 계승)

| 도구                       | 역할             | Guild Board 추가 범위           |
| -------------------------- | ---------------- | ------------------------------- |
| Minitest                   | 단위/통합 테스트 | 모델, 컨트롤러, MCP 도구 테스트 |
| Capybara + headless Chrome | 시스템 테스트    | 칸반 보드 드래그앤드롭 E2E      |
| rubocop-rails-omakase      | 코드 스타일      | 신규 코드에도 동일 적용         |
| Brakeman                   | 보안 스캔        | MCP 엔드포인트 포함             |

### 7.1 MCP 도구 테스트 전략

```ruby
# test/tools/create_task_tool_test.rb
# fast-mcp의 도구를 직접 단위 테스트
# MCP Inspector (npx @modelcontextprotocol/inspector)로 통합 검증
```

---

## 8. 배포 구성 (보일러플레이트 계승 + 확장)

### 8.1 서버 역할

| 역할    | 프로세스          | 비고                                   |
| ------- | ----------------- | -------------------------------------- |
| **web** | Thruster + Puma   | 웹 UI + MCP 엔드포인트 (같은 프로세스) |
| **job** | SolidQueue worker | 활동 로그 비동기 기록                  |

### 8.2 Procfile.dev (개발 환경)

```
web: bin/rails server -p 3000
css: bin/rails tailwindcss:watch
jobs: bin/jobs
```

> MCP 서버는 별도 프로세스가 아니라 Rails 앱의 Rack 미들웨어로 동작하므로 추가 프로세스 불필요.

### 8.3 환경 변수 (Guild Board 추가분)

| 변수                  | 설명                             | 기본값                        |
| --------------------- | -------------------------------- | ----------------------------- |
| `MCP_ALLOWED_ORIGINS` | MCP 요청 허용 Origin (쉼표 구분) | `*` (개발), 프로덕션에서 제한 |
| `MCP_RATE_LIMIT`      | MCP 요청 분당 제한               | `60`                          |
| `PROJECT_KEY_SALT`    | 프로젝트 키 해싱 솔트            | Rails credentials에 저장      |

---

## 9. 디렉토리 구조 (Guild Board 추가분)

보일러플레이트가 생성한 구조에 아래가 추가된다:

```
guild_board/
├── app/
│   ├── channels/
│   │   └── board_channel.rb              # 프로젝트별 실시간 채널
│   ├── components/                        # (기존 10종 + 신규 6종)
│   │   ├── kanban_column_component.rb
│   │   ├── task_card_component.rb
│   │   ├── activity_log_component.rb
│   │   ├── project_key_component.rb
│   │   ├── filter_bar_component.rb
│   │   └── checklist_component.rb
│   ├── controllers/
│   │   ├── projects_controller.rb
│   │   ├── boards_controller.rb
│   │   ├── tasks_controller.rb
│   │   ├── columns_controller.rb
│   │   ├── comments_controller.rb
│   │   ├── checklists_controller.rb
│   │   ├── labels_controller.rb
│   │   ├── project_keys_controller.rb
│   │   ├── activity_logs_controller.rb
│   │   └── concerns/
│   │       └── mcp_authentication.rb      # MCP 프로젝트 키 인증
│   ├── javascript/controllers/            # (기존 4종 + 신규 5종)
│   │   ├── drag_controller.js
│   │   ├── filter_controller.js
│   │   ├── board_controller.js
│   │   ├── clipboard_controller.js
│   │   └── checklist_controller.js
│   ├── jobs/
│   │   └── activity_log_job.rb            # 활동 로그 비동기 기록
│   ├── models/
│   │   ├── project.rb
│   │   ├── project_key.rb
│   │   ├── column.rb
│   │   ├── task.rb
│   │   ├── label.rb
│   │   ├── task_label.rb
│   │   ├── checklist.rb
│   │   ├── comment.rb
│   │   └── activity_log.rb
│   ├── policies/
│   │   ├── project_policy.rb
│   │   ├── task_policy.rb
│   │   └── project_key_policy.rb
│   ├── tools/                             # fast-mcp 도구
│   │   ├── application_tool.rb
│   │   ├── list_tasks_tool.rb
│   │   ├── get_task_tool.rb
│   │   ├── create_task_tool.rb
│   │   ├── update_task_tool.rb
│   │   ├── move_task_tool.rb
│   │   ├── add_comment_tool.rb
│   │   ├── update_checklist_tool.rb
│   │   └── list_columns_tool.rb
│   └── views/
│       ├── projects/
│       ├── boards/
│       ├── tasks/
│       └── components/                    # 신규 ViewComponent ERB
├── config/
│   └── initializers/
│       └── fast_mcp.rb                    # MCP 서버 설정
├── db/
│   └── migrate/                           # Guild Board 신규 마이그레이션
│       ├── XXXXXX_create_projects.rb
│       ├── XXXXXX_create_project_keys.rb
│       ├── XXXXXX_create_columns.rb
│       ├── XXXXXX_create_tasks.rb
│       ├── XXXXXX_create_labels.rb
│       ├── XXXXXX_create_task_labels.rb
│       ├── XXXXXX_create_checklists.rb
│       ├── XXXXXX_create_comments.rb
│       └── XXXXXX_create_activity_logs.rb
└── test/
    ├── models/                            # 신규 모델 테스트
    ├── controllers/                       # 신규 컨트롤러 테스트
    ├── components/                        # 신규 ViewComponent 테스트
    ├── policies/                          # 신규 Pundit 정책 테스트
    ├── tools/                             # MCP 도구 테스트
    └── system/                            # 칸반 보드 E2E 테스트
```

---

## 10. 버전 호환성 매트릭스

| 기술 A            | 기술 B              | 호환성 확인                          |
| ----------------- | ------------------- | ------------------------------------ |
| Ruby ~> 3.4       | fast-mcp ~> 1.5     | fast-mcp requires Ruby >= 3.0.0 ✅   |
| Rails ~> 8.1      | fast-mcp ~> 1.5     | Rack 미들웨어 방식, Rails 7+ 호환 ✅ |
| Rails ~> 8.1      | Rack >= 2.0         | Rails 8.1 uses Rack 3.x ✅           |
| Import Maps       | SortableJS 1.15     | ESM 빌드 지원, CDN 로드 가능 ✅      |
| Stimulus ~> 1.3   | SortableJS 1.15     | Stimulus 컨트롤러에서 래핑 ✅        |
| SolidCable ~> 3.0 | Action Cable        | Rails 8 기본 통합 ✅                 |
| PostgreSQL 17     | jsonb, GIN 인덱스   | PostgreSQL 9.4+ 지원 ✅              |
| fast-mcp ~> 1.5   | MCP spec 2025-06-18 | Streamable HTTP + SSE 지원 ✅        |

---

## 11. 기술 부채 및 마이그레이션 계획

### 11.1 MCP 공식 Ruby SDK 전환 검토

현재 fast-mcp를 채택하지만, Anthropic 공식 `mcp` 젬이 1.0에 도달하고 Rails 통합이 성숙하면 전환을 검토한다.

| 조건            | 현재 상태          | 전환 트리거                 |
| --------------- | ------------------ | --------------------------- |
| mcp 젬 버전     | 0.6.0 (2026-01-16) | 1.0 stable 릴리스           |
| Rails Rack 통합 | 미지원             | 공식 Rails 미들웨어 제공 시 |
| Streamable HTTP | stdio 중심         | HTTP 트랜스포트 안정화 시   |

### 11.2 Solid Stack → Redis 마이그레이션

보일러플레이트 README 섹션 H에 정의된 스케일링 가이드를 따른다. 동시 접속 에이전트 수가 증가하여 PostgreSQL 기반 SolidCable에 병목이 생기면 Redis 전환을 검토한다.

---

## 12. 보안 고려사항

| 영역                 | 대응                                                              |
| -------------------- | ----------------------------------------------------------------- |
| **프로젝트 키 저장** | bcrypt 해시 저장 (평문 저장 금지), 키 생성 시 한 번만 노출        |
| **MCP Origin 검증**  | fast-mcp의 Origin 헤더 검증 활성화, 프로덕션에서 허용 Origin 제한 |
| **Rate Limit**       | Rails 8 rate_limit + SolidCache, MCP 엔드포인트에 분당 60회 제한  |
| **CSRF**             | MCP 엔드포인트는 API이므로 CSRF 면제, 프로젝트 키로 인증          |
| **SQL Injection**    | ActiveRecord 파라미터 바인딩 (Rails 기본)                         |
| **XSS**              | ERB 자동 이스케이프 (Rails 기본)                                  |
