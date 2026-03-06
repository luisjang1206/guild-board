# ROADMAP

> **버전**: v1.0
> **작성일**: 2026-03-06
> **기반 문서**: [PRD v1.1](./PRD_v1.1.md), [TSD v1.0](./TSD_v1.0.md)
> **추정 기준**: 1인 풀타임 개발 기준
> **전체 일정**: 28-37일 (현실적 8-10주, fast-mcp 학습 곡선 및 기술적 장애물 포함)
> **크리티컬 패스**: Phase 2 (칸반 UI) + Phase 4 (MCP 서버)

---

## 프로젝트 개요

Guild Board는 AI 코딩 에이전트와 사람이 동일한 칸반 보드에서 협업하는 웹 서비스다. 에이전트는 MCP(Model Context Protocol)를 통해 태스크를 조회/생성/이동하고, 모든 변경이 실시간으로 보드에 반영된다.

보일러플레이트(ror-hatchling)에서 인증, Admin 패널, ViewComponent 11종, Stimulus 4종, Multi-DB, Kamal 배포 등이 이미 구현된 상태에서, Guild Board 고유 도메인 기능을 구현한다.

### 핵심 목표
- 8개 도메인 테이블 기반의 프로젝트/칸반 보드 시스템
- SortableJS 기반 드래그앤드롭 칸반 UI
- Action Cable + Turbo Streams 실시간 업데이트
- fast-mcp 기반 MCP 서버 (8개 도구, 프로젝트 키 인증)
- 활동 타임라인 (사람/에이전트 구분)

### 복잡도 기준
| 등급 | 설명 | 예상 소요 |
|------|------|-----------|
| S | 단순 설정, 보일러플레이트 패턴 반복 | 1-2시간 |
| M | 약간의 비즈니스 로직 포함 | 반나절-1일 |
| L | 복잡한 로직 또는 새로운 UI 패턴 | 1-2일 |
| XL | 다중 기술 통합, 새로운 아키텍처 패턴 | 2일 이상 |

### 테스트 원칙

기능 구현 시 기본 테스트(정상 동작, 주요 유효성 검증)를 함께 작성한다. 각 Phase 말미의 테스트 마일스톤에서는 경계 케이스, 통합 시나리오, 회귀 테스트를 보강한다.

---

## Phase 1: 도메인 모델 & 프로젝트 관리 (예상 3-4일)

**목표:** 8개 도메인 테이블을 생성하고, 프로젝트 CRUD와 키 관리를 구현한다. Phase 1 완료 시 사용자가 프로젝트를 생성하고 API 키를 발급받을 수 있다.

### 마일스톤 1.1: 데이터베이스 마이그레이션

- [ ] `create_projects` 마이그레이션 (user_id FK, name, description) `[복잡도: S]` `[의존성: 없음]`
- [ ] `create_project_keys` 마이그레이션 (project_id FK, key_digest, key_prefix, name, permissions jsonb, active, last_used_at) `[복잡도: S]` `[의존성: 마일스톤 1.1 projects]`
- [ ] `create_board_columns` 마이그레이션 (project_id FK, name, position) `[복잡도: S]` `[의존성: 마일스톤 1.1 projects]`
- [ ] `create_tasks` 마이그레이션 (project_id FK, board_column_id FK, title, description, priority enum, position, creator_type, creator_id, deleted_at) `[복잡도: S]` `[의존성: 마일스톤 1.1 board_columns]`
- [ ] `create_labels` 마이그레이션 (project_id FK, name, color) `[복잡도: S]` `[의존성: 마일스톤 1.1 projects]`
- [ ] `create_task_labels` 마이그레이션 (task_id FK, label_id FK, 복합 유니크 인덱스) `[복잡도: S]` `[의존성: 마일스톤 1.1 tasks, labels]`
- [ ] `create_checklists` 마이그레이션 (task_id FK, content, completed, position) `[복잡도: S]` `[의존성: 마일스톤 1.1 tasks]`
- [ ] `create_comments` 마이그레이션 (task_id FK, author_type, author_id, content) `[복잡도: S]` `[의존성: 마일스톤 1.1 tasks]`
- [ ] `create_activity_logs` 마이그레이션 (project_id FK, task_id FK nullable, actor_type, actor_id, action, changes jsonb, updated_at 없음) `[복잡도: S]` `[의존성: 마일스톤 1.1 projects]`
- [ ] PostgreSQL 고유 기능 적용: jsonb 칼럼 GIN 인덱스, tasks 부분 인덱스 (WHERE deleted_at IS NULL) `[복잡도: S]` `[의존성: 위 마이그레이션 전체]`

### 마일스톤 1.2: 모델 정의

- [ ] Project 모델 (belongs_to :user, has_many 관계, 유효성 검증) `[복잡도: M]` `[의존성: 마일스톤 1.1]`
- [ ] BoardColumn 모델 (belongs_to :project, has_many :tasks, position 관리 scope) `[복잡도: S]` `[의존성: 마일스톤 1.1]`
- [ ] Task 모델 (belongs_to :project/:board_column, priority enum, 소프트 삭제 scope, position 관리) `[복잡도: M]` `[의존성: 마일스톤 1.1]`
- [ ] Label 모델, TaskLabel 조인 모델 `[복잡도: S]` `[의존성: 마일스톤 1.1]`
- [ ] Checklist 모델 (belongs_to :task, position 관리) `[복잡도: S]` `[의존성: 마일스톤 1.1]`
- [ ] Comment 모델 (belongs_to :task, author_type/author_id) `[복잡도: S]` `[의존성: 마일스톤 1.1]`
- [ ] ActivityLog 모델 (append-only, 읽기 전용 패턴) `[복잡도: S]` `[의존성: 마일스톤 1.1]`
- [ ] ProjectKey 모델 (bcrypt 해시 저장, key_prefix 추출, 키 생성/검증 메서드, permissions jsonb) `[복잡도: L]` `[의존성: 마일스톤 1.1]`
- [ ] Project#after_create 콜백: 기본 5개 BoardColumn 자동 생성 (Backlog, Todo, In Progress, Review, Done) `[복잡도: S]` `[의존성: 마일스톤 1.2 Project/BoardColumn 모델]`
- [ ] Project#after_create 콜백: 기본 ProjectKey 1개 자동 생성 (전체 권한, 이름: 'Default') `[복잡도: S]` `[의존성: 마일스톤 1.2 Project/ProjectKey 모델]`
- [ ] User 모델 확장: has_many :projects 관계 추가 `[복잡도: S]` `[의존성: 마일스톤 1.2 Project 모델]`

### 마일스톤 1.3: Pundit 정책

- [ ] ProjectPolicy (소유자만 CRUD, index는 인증된 사용자 전체) `[복잡도: M]` `[의존성: 마일스톤 1.2]`
- [ ] TaskPolicy (프로젝트 소유자만 CRUD) `[복잡도: S]` `[의존성: 마일스톤 1.2]`
- [ ] ProjectKeyPolicy (프로젝트 소유자만 키 관리) `[복잡도: S]` `[의존성: 마일스톤 1.2]`
- [ ] 정책 테스트 작성 (test/policies/) `[복잡도: M]` `[의존성: 마일스톤 1.3 정책 전체]`

### 마일스톤 1.4: 프로젝트 CRUD & 키 관리

- [ ] 라우트 정의: projects 리소스 및 project_keys 중첩 리소스 (PRD 7절 참조) `[복잡도: S]` `[의존성: 마일스톤 1.3]`
- [ ] ProjectsController (index, show, new, create, edit, update, destroy) `[복잡도: M]` `[의존성: 마일스톤 1.4 라우트]`
- [ ] 프로젝트 뷰 (목록, 상세, 생성/수정 폼) — 기존 ViewComponent 활용 (Card, Button, FormField, EmptyState) `[복잡도: M]` `[의존성: 마일스톤 1.4 컨트롤러]`
- [ ] ProjectKeysController (index, create, destroy, regenerate, toggle_active) `[복잡도: L]` `[의존성: 마일스톤 1.4 라우트]`
- [ ] ProjectKeyComponent (키 표시/복사 UI) `[복잡도: M]` `[의존성: 마일스톤 1.4 컨트롤러]`
- [ ] clipboard_controller.js (Stimulus - 클립보드 복사) `[복잡도: S]` `[의존성: 없음]`
- [ ] Seeds 확장: 샘플 프로젝트, BoardColumn, 태스크, 라벨 데이터 `[복잡도: S]` `[의존성: 마일스톤 1.2]`
- [ ] i18n 추가: 프로젝트/키 관련 번역 (EN/KO) `[복잡도: S]` `[의존성: 없음]`

### 마일스톤 1.5: Phase 1 테스트

- [ ] 모델 단위 테스트: 8개 모델의 유효성 검증, 관계, scope, 콜백 `[복잡도: M]` `[의존성: 마일스톤 1.2]`
- [ ] 컨트롤러 통합 테스트: ProjectsController, ProjectKeysController `[복잡도: M]` `[의존성: 마일스톤 1.4]`
- [ ] Fixtures 작성: projects, board_columns, tasks, labels 등 `[복잡도: S]` `[의존성: 마일스톤 1.2]`

**기술 참고:**
- **BoardColumn 모델명**: PRD/TSD에서는 `columns` 테이블로 정의하고 있지만, `Column`은 `ActiveRecord::ConnectionAdapters::Column`과 혼동을 유발하고, `Model.columns` 메서드와 충돌 가능하므로 `BoardColumn` (테이블: `board_columns`)으로 변경한다. 기술 결정 사항 7번 참조.
- **Position 관리**: `acts_as_list` 젬 없이 Rails 기본 기능으로 구현. 이동 시 대상 position 설정 후 같은 scope 내 position 재정렬하는 메서드를 모델에 정의한다.
- **소프트 삭제**: `deleted_at` 칼럼 + `default_scope` 대신 명시적 scope (`scope :active, -> { where(deleted_at: nil) }`)를 사용한다. default_scope는 예기치 않은 동작을 유발할 수 있으므로 피한다. v1에서는 DB 레벨 복구만 지원하며, 복구 UI는 향후 버전에서 구현한다.
- **프로젝트 키**: `has_secure_password`와 유사한 패턴으로 bcrypt 해시를 직접 관리한다. `SecureRandom.base58(24)`로 키를 생성하고, `BCrypt::Password.create`로 해시 저장한다.
- **초기 마이그레이션**: 개별 파일로 생성하되, Phase 1 완료 시 아직 프로덕션 배포 전이라면 `rails db:migrate:reset`으로 깔끔하게 재적용한다.

---

## Phase 2: 칸반 보드 UI & 태스크 관리 (예상 10-14일) **[크리티컬 패스]**

**목표:** 프로젝트의 칸반 보드 뷰를 구현하고, 태스크 CRUD, 드래그앤드롭, 라벨/체크리스트/코멘트, 필터링을 완성한다. Phase 2 완료 시 사용자가 칸반 보드에서 모든 태스크 관리 작업을 수행할 수 있다 (실시간은 아직 미지원).

### 마일스톤 2.1: 보드 뷰 기본 구조

- [ ] 라우트 정의: boards, tasks (중첩), board_columns, labels, comments, checklists (PRD 7절 참조) `[복잡도: S]` `[의존성: Phase 1]`
- [ ] BoardsController#show (프로젝트의 칸반 보드 뷰) `[복잡도: M]` `[의존성: 마일스톤 2.1 라우트]`
- [ ] KanbanColumnComponent (칼럼 컨테이너, 태스크 카드 슬롯, 카드 카운트) `[복잡도: L]` `[의존성: 마일스톤 2.1 컨트롤러]`
- [ ] TaskCardComponent (제목, 우선순위 Badge, 라벨, 체크리스트 진행률, 코멘트 수, 생성자 구분) `[복잡도: L]` `[의존성: 마일스톤 2.1 컨트롤러]`
- [ ] 보드 레이아웃: 수평 스크롤 칼럼, Tailwind CSS v4 스타일링 `[복잡도: M]` `[의존성: 마일스톤 2.1 컴포넌트]`
- [ ] Navbar 확장: 프로젝트 네비게이션 추가 `[복잡도: S]` `[의존성: Phase 1]`

### 마일스톤 2.2: 태스크 CRUD

- [ ] TasksController (new, create, show, edit, update, destroy — 소프트 삭제) `[복잡도: M]` `[의존성: 마일스톤 2.1]`
- [ ] 태스크 생성 폼 (Modal 활용, 제목/설명/우선순위/칼럼 선택) `[복잡도: M]` `[의존성: 마일스톤 2.2 컨트롤러]`
- [ ] 태스크 상세 뷰 (Modal 또는 별도 페이지, 전체 정보 표시) `[복잡도: M]` `[의존성: 마일스톤 2.2 컨트롤러]`
- [ ] 태스크 수정/삭제 UI `[복잡도: S]` `[의존성: 마일스톤 2.2 컨트롤러]`
- [ ] Turbo Frame으로 태스크 CRUD 시 보드 부분 갱신 `[복잡도: M]` `[의존성: 마일스톤 2.2 뷰]`

### 마일스톤 2.3: 카드 드래그앤드롭

- [ ] SortableJS Import Maps 핀 추가 (`config/importmap.rb`) `[복잡도: S]` `[의존성: 없음]`
- [ ] CSP 업데이트: `script_src`에 `cdn.jsdelivr.net` 추가 `[복잡도: S]` `[의존성: 없음]`
- [ ] drag_controller.js (Stimulus): SortableJS 래핑, 칼럼 간 카드 이동 `[복잡도: L]` `[의존성: 마일스톤 2.1]`
- [ ] TasksController#move 액션 (PATCH, 칼럼/position 변경) `[복잡도: M]` `[의존성: 마일스톤 2.2]`
- [ ] 드래그 시 시각적 피드백 (고스트, 플레이스홀더) — Tailwind 스타일 `[복잡도: S]` `[의존성: 마일스톤 2.3 drag_controller]`

### 마일스톤 2.4: 라벨, 체크리스트, 코멘트

- [ ] LabelsController (index, create, update, destroy — 프로젝트 범위) `[복잡도: M]` `[의존성: Phase 1]`
- [ ] 라벨 관리 UI (프로젝트 설정 내 라벨 CRUD, 색상 선택) `[복잡도: M]` `[의존성: 마일스톤 2.4 컨트롤러]`
- [ ] 태스크에 라벨 부착/해제 UI `[복잡도: M]` `[의존성: 마일스톤 2.2, 마일스톤 2.4 라벨]`
- [ ] ChecklistsController (create, update, destroy) `[복잡도: S]` `[의존성: Phase 1]`
- [ ] ChecklistComponent (체크리스트 위젯, 진행률 바) `[복잡도: M]` `[의존성: 마일스톤 2.4 컨트롤러]`
- [ ] checklist_controller.js (Stimulus: 인라인 추가, 체크 토글) `[복잡도: M]` `[의존성: 마일스톤 2.4 ChecklistComponent]`
- [ ] CommentsController#create (태스크 하위 리소스) `[복잡도: S]` `[의존성: Phase 1]`
- [ ] 코멘트 목록 & 작성 UI (태스크 상세 뷰 내) `[복잡도: M]` `[의존성: 마일스톤 2.2 태스크 상세]`

### 마일스톤 2.5: 칼럼 관리 & 필터링

- [ ] BoardColumnsController (create, update, destroy, move) `[복잡도: M]` `[의존성: Phase 1]`
- [ ] 칼럼 추가/삭제/이름 변경 UI (보드 뷰 내 인라인) `[복잡도: M]` `[의존성: 마일스톤 2.5 컨트롤러]`
- [ ] 칼럼 순서 드래그앤드롭 (BoardColumnsController#move) `[복잡도: M]` `[의존성: 마일스톤 2.5 컨트롤러, 마일스톤 2.3 drag_controller]`
- [ ] FilterBarComponent (담당자 타입, 라벨, 우선순위, 칼럼 필터) `[복잡도: L]` `[의존성: 마일스톤 2.4]`
- [ ] filter_controller.js (Stimulus: 필터 상태 관리, Turbo Frame으로 필터 적용) `[복잡도: M]` `[의존성: 마일스톤 2.5 FilterBarComponent]`
- [ ] 보드 뷰에서 필터 파라미터 처리 (BoardsController) `[복잡도: M]` `[의존성: 마일스톤 2.5 filter_controller]`

### 마일스톤 2.6: Phase 2 테스트

- [ ] ViewComponent 단위 테스트: KanbanColumn, TaskCard, Checklist, FilterBar `[복잡도: M]` `[의존성: 마일스톤 2.1, 2.4, 2.5]`
- [ ] 컨트롤러 통합 테스트: Boards, Tasks, BoardColumns, Labels, Checklists, Comments `[복잡도: L]` `[의존성: 마일스톤 2.2-2.5]`
- [ ] 시스템 테스트: 태스크 생성 -> 보드에서 확인 -> 수정 -> 삭제 플로우 `[복잡도: M]` `[의존성: 마일스톤 2.2]`
- [ ] i18n 추가: 보드/태스크/라벨/코멘트 관련 번역 (EN/KO) `[복잡도: S]` `[의존성: 없음]`

**기술 참고:**
- **SortableJS 설정**: `group: "board"`로 칼럼 간 카드 이동 허용. `onEnd` 콜백에서 Turbo fetch로 PATCH 요청 전송.
- **Turbo Stream 호환 DOM ID 규칙 사전 적용**: Phase 3의 Turbo Stream 브로드캐스트에서 사용할 DOM ID 규칙(`board_column_{id}_tasks`, `task_{id}`)을 Phase 2에서 미리 적용한다. 이를 통해 Phase 3에서 뷰 재작업 없이 브로드캐스트만 추가할 수 있다.
- **필터링**: URL 파라미터 기반 (`?priority=high&label=frontend`). Turbo Frame으로 보드 영역만 갱신하여 페이지 전체 리로드 방지.
- **소프트 삭제 UI**: 삭제 시 확인 Modal 표시, 실제로는 `deleted_at` 타임스탬프 설정. v1에서는 복구 UI 없이 DB 레벨 복구만 가능.

---

## Phase 3: 실시간 업데이트 (예상 3-4일)

**목표:** Action Cable과 Turbo Streams를 통합하여, 한 사용자(또는 에이전트)의 변경이 같은 보드를 보고 있는 모든 사용자에게 즉시 반영되도록 한다.

### 마일스톤 3.1: Action Cable 채널

- [ ] BoardChannel 구현 (프로젝트별 스트림, 구독 시 프로젝트 접근 권한 확인) `[복잡도: M]` `[의존성: Phase 2]`
- [ ] CSP 업데이트: `connect_src`에 WebSocket 도메인(`wss:`) 추가 `[복잡도: S]` `[의존성: 없음]`
- [ ] ApplicationCable::Connection 검토: MCP 브로드캐스트는 서버 측에서 `ActionCable.server.broadcast`를 호출하므로 Connection 인증 변경 불필요함을 확인. BoardChannel#subscribed에서 프로젝트 접근 권한만 확인 `[복잡도: S]` `[의존성: 마일스톤 3.1 BoardChannel]`
- [ ] board_controller.js (Stimulus: Action Cable 구독 관리, 연결 상태 UI 표시) `[복잡도: M]` `[의존성: 마일스톤 3.1 BoardChannel]`

### 마일스톤 3.2: Turbo Streams 브로드캐스트

- [ ] 태스크 생성 브로드캐스트: `turbo_stream.append` — 해당 칼럼에 TaskCard 추가 `[복잡도: M]` `[의존성: 마일스톤 3.1]`
- [ ] 태스크 이동 브로드캐스트: `turbo_stream.remove` + `turbo_stream.append` — 카드를 이전 칼럼에서 제거하고 새 칼럼에 추가 `[복잡도: L]` `[의존성: 마일스톤 3.1]`
- [ ] 태스크 수정 브로드캐스트: `turbo_stream.replace` — 카드 내용 갱신 `[복잡도: S]` `[의존성: 마일스톤 3.1]`
- [ ] 태스크 삭제 브로드캐스트: `turbo_stream.remove` — 카드 제거 `[복잡도: S]` `[의존성: 마일스톤 3.1]`
- [ ] 코멘트 추가 브로드캐스트: `turbo_stream.append` — 코멘트 목록에 추가 `[복잡도: S]` `[의존성: 마일스톤 3.1]`
- [ ] 체크리스트 변경 브로드캐스트: `turbo_stream.replace` — 체크리스트 영역 갱신 `[복잡도: S]` `[의존성: 마일스톤 3.1]`
- [ ] 칼럼 변경 브로드캐스트 (추가/삭제/이름변경/순서변경) `[복잡도: M]` `[의존성: 마일스톤 3.1]`

### 마일스톤 3.3: 실시간 UX 보강

- [ ] 브로드캐스트 시 SortableJS 인스턴스 재초기화 처리 (Turbo 이벤트 리스너) `[복잡도: M]` `[의존성: 마일스톤 3.2]`
- [ ] 드래그 중 외부 업데이트 충돌 방지 로직 `[복잡도: XL]` `[의존성: 마일스톤 3.2]`
- [ ] 연결 끊김/재연결 시 보드 상태 동기화 `[복잡도: M]` `[의존성: 마일스톤 3.1]`

### 마일스톤 3.4: Phase 3 테스트

- [ ] Action Cable 채널 테스트 (구독, 권한, 브로드캐스트) `[복잡도: M]` `[의존성: 마일스톤 3.1]`
- [ ] Turbo Streams 통합 테스트 `[복잡도: M]` `[의존성: 마일스톤 3.2]`
- [ ] 시스템 테스트: 두 브라우저 세션에서 실시간 동기화 확인 `[복잡도: L]` `[의존성: 마일스톤 3.2]`

**기술 참고:**
- **브로드캐스트 패턴**: 컨트롤러 액션 완료 후 `broadcast_*_to`를 호출한다. 모델 콜백에서의 브로드캐스트는 트랜잭션 타이밍 이슈를 유발할 수 있으므로, `after_commit` 콜백 또는 컨트롤러에서 명시적으로 호출하는 것을 권장한다.
- **Turbo Stream 타겟 규칙**: 각 칼럼은 `turbo-frame` 또는 고유 DOM ID (`board_column_#{id}_tasks`)로 래핑하여 정확한 append/remove 타겟을 보장한다.
- **SolidCable**: Redis 없이 PostgreSQL 기반으로 동작하므로 추가 인프라 불필요. 동시 접속이 증가하면 TSD 11.2절에 따라 Redis 전환을 검토한다.
- **드래그 중 충돌 방지 전략**: 드래그 중에는 해당 보드의 Turbo Stream 업데이트를 일시 중단하고, 드래그 완료 후 전체 보드 상태를 서버에서 다시 fetch하는 방식을 검토한다. 또는 드래그 중 수신된 업데이트를 큐에 저장했다가 드래그 완료 후 일괄 적용하는 방식도 고려한다.

---

## Phase 4: MCP 서버 (예상 5-7일) **[크리티컬 패스]**

**목표:** fast-mcp 젬을 통합하여 AI 에이전트가 프로젝트 키로 인증하고 8개 도구를 사용할 수 있도록 한다. MCP를 통한 변경도 실시간으로 보드에 반영된다.

### 마일스톤 4.1: fast-mcp 설치 및 기본 설정

- [ ] fast-mcp 최신 버전 확인 및 CHANGELOG 검토 (구현 시작 시점) `[복잡도: S]` `[의존성: 없음]`
- [ ] Gemfile에 `gem "fast-mcp", "~> 1.5"` 추가 및 `bundle install` `[복잡도: S]` `[의존성: 마일스톤 4.1 버전 확인]`
- [ ] `bin/rails generate fast_mcp:install` 실행 (initializer, ApplicationTool 등 생성) `[복잡도: S]` `[의존성: 마일스톤 4.1 젬 설치]`
- [ ] `config/initializers/fast_mcp.rb` 설정 (path_prefix: "/mcp", name, version, allowed_origins) `[복잡도: M]` `[의존성: 마일스톤 4.1 generator]`
- [ ] 환경변수 설정: `MCP_ALLOWED_ORIGINS`, `MCP_RATE_LIMIT`, `PROJECT_KEY_SALT` (Rails credentials) `[복잡도: S]` `[의존성: 없음]`
- [ ] fast-mcp PoC: 단일 도구(list_columns)로 프로젝트 키 인증 -> 도구 호출 -> 응답 확인 `[복잡도: M]` `[의존성: 마일스톤 4.1 설정, Phase 1 ProjectKey 모델]`

### 마일스톤 4.2: 프로젝트 키 인증

- [ ] McpAuthentication concern 구현 (X-Project-Key 헤더 검증, Current.project 바인딩) `[복잡도: L]` `[의존성: 마일스톤 4.1 PoC]`
- [ ] ApplicationTool에 인증 모듈 통합 (fast-mcp의 `authorize` 블록 활용) `[복잡도: M]` `[의존성: 마일스톤 4.2 concern]`
- [ ] X-Agent-Name 헤더에서 에이전트 이름 추출 및 컨텍스트 바인딩 `[복잡도: S]` `[의존성: 마일스톤 4.2 concern]`
- [ ] 키별 권한 검증: permissions jsonb에서 요청 도구 허용 여부 확인 `[복잡도: M]` `[의존성: 마일스톤 4.2 concern]`
- [ ] 비활성 키 / 유효하지 않은 키 -> 401/403 에러 반환 `[복잡도: S]` `[의존성: 마일스톤 4.2 concern]`
- [ ] last_used_at 갱신 (인증 성공 시) `[복잡도: S]` `[의존성: 마일스톤 4.2 concern]`

### 마일스톤 4.3: MCP 도구 구현 (8개)

- [ ] ListTasksTool (board_column/label/priority 선택적 필터링) `[복잡도: M]` `[의존성: 마일스톤 4.2]`
- [ ] GetTaskTool (태스크 상세 조회, 체크리스트/코멘트/라벨 포함) `[복잡도: M]` `[의존성: 마일스톤 4.2]`
- [ ] CreateTaskTool (title 필수, description/board_column/priority 선택) `[복잡도: M]` `[의존성: 마일스톤 4.2]`
- [ ] UpdateTaskTool (title/description/priority 선택적 수정) `[복잡도: M]` `[의존성: 마일스톤 4.2]`
- [ ] MoveTaskTool (칼럼명 또는 ID로 이동) `[복잡도: M]` `[의존성: 마일스톤 4.2]`
- [ ] AddCommentTool (task_id, content) `[복잡도: S]` `[의존성: 마일스톤 4.2]`
- [ ] UpdateChecklistTool (checklist_item_id, completed 토글) `[복잡도: S]` `[의존성: 마일스톤 4.2]`
- [ ] ListColumnsTool (현재 보드의 BoardColumn 목록) `[복잡도: S]` `[의존성: 마일스톤 4.2]`

### 마일스톤 4.4: MCP-실시간 연동

- [ ] MCP 도구에서 DB 변경 후 Action Cable 브로드캐스트 트리거 `[복잡도: M]` `[의존성: 마일스톤 4.3, Phase 3]`
- [ ] MCP를 통한 태스크 생성/이동이 웹 UI에 즉시 반영되는지 확인 `[복잡도: M]` `[의존성: 마일스톤 4.4 브로드캐스트]`
- [ ] creator_type/author_type을 "agent"로, creator_id/author_id를 X-Agent-Name으로 설정 `[복잡도: S]` `[의존성: 마일스톤 4.3]`

### 마일스톤 4.5: Rate Limit & 보안

- [ ] MCP 엔드포인트 Rate Limit 적용 (분당 60회, SolidCache 백엔드). fast-mcp Rack 미들웨어와 Rails `rate_limit`의 호환성 확인 — 호환되지 않을 경우 커스텀 Rack 미들웨어(`Rack::Attack` 패턴) 또는 fast-mcp의 before 훅으로 대안 구현 `[복잡도: M]` `[의존성: 마일스톤 4.1]`
- [ ] MCP 엔드포인트 CSRF 면제 설정 `[복잡도: S]` `[의존성: 마일스톤 4.1]`
- [ ] fast-mcp Origin 헤더 검증 활성화 (프로덕션 환경) `[복잡도: S]` `[의존성: 마일스톤 4.1]`
- [ ] Lograge에 MCP 요청 로깅 포함 `[복잡도: S]` `[의존성: 마일스톤 4.1]`

### 마일스톤 4.6: Phase 4 테스트

- [ ] MCP 도구 단위 테스트 (test/tools/ — 8개 도구 각각) `[복잡도: L]` `[의존성: 마일스톤 4.3]`
- [ ] MCP 인증 통합 테스트 (유효 키, 무효 키, 비활성 키, 권한 부족) `[복잡도: M]` `[의존성: 마일스톤 4.2]`
- [ ] MCP-실시간 연동 통합 테스트 (도구 호출 -> 브로드캐스트 확인) `[복잡도: M]` `[의존성: 마일스톤 4.4]`
- [ ] MCP Inspector (`npx @modelcontextprotocol/inspector`)로 수동 통합 검증 `[복잡도: M]` `[의존성: 마일스톤 4.3]`
- [ ] i18n 추가: MCP 에러 메시지 번역 `[복잡도: S]` `[의존성: 없음]`

**기술 참고:**
- **fast-mcp 도구 정의**: `FastMcp::Tool`을 상속하고, `arguments` 블록에서 Dry::Schema로 인자를 정의하며, `call` 메서드에서 비즈니스 로직을 실행한다.
- **fast-mcp 인증**: `authorize` 블록을 ApplicationTool에 정의하여 모든 도구에 공통 인증을 적용한다. `headers` 메서드로 요청 헤더에 접근할 수 있다.
- **MCP 프로토콜**: fast-mcp는 SSE(레거시) + Streamable HTTP(권장) 모두 지원. 경로는 `/mcp/sse` (SSE), `/mcp/messages` (메시지).
- **Rate Limit**: `rate_limit to: 60, within: 1.minute, by: -> { request.headers["X-Project-Key"]&.first(8) || request.ip }` 로 키별 제한 가능. 단, fast-mcp가 Rack 미들웨어로 동작하므로 Rails 컨트롤러 레벨의 `rate_limit`이 적용되지 않을 수 있다. 이 경우 커스텀 Rack 미들웨어로 구현한다.
- **MCP 라우트 방식**: PRD 7절의 `namespace :api do namespace :mcp` 대신, fast-mcp의 Rack 미들웨어로 `/mcp` 경로에 마운트된다. Rails 라우터를 거치지 않으므로 별도의 `Api::McpController`는 생성하지 않는다. 기술 결정 사항 8번 참조.
- **`last_used_at` 갱신 빈도 제한**: 매 MCP 요청마다 DB UPDATE가 발생하면 성능 부담이 크므로, 5분 간격으로 `touch` 빈도를 제한하는 방안을 적용한다. 예: `project_key.update_column(:last_used_at, Time.current) if project_key.last_used_at.nil? || project_key.last_used_at < 5.minutes.ago`

---

## Phase 5: 활동 타임라인 & Admin 확장 (예상 4-5일)

**목표:** 모든 변경 이력을 활동 로그로 기록하고, 보드/카드별 타임라인 뷰를 제공한다. Admin 패널을 확장하여 전체 프로젝트와 키를 관리한다.

### 마일스톤 5.1: 활동 로그 기록

- [ ] ActivityLogJob 구현 (SolidQueue 비동기 잡) `[복잡도: M]` `[의존성: Phase 1 ActivityLog 모델]`
- [ ] 웹 UI 변경에 활동 로그 기록 연동 (컨트롤러 after_action 또는 서비스 객체) `[복잡도: L]` `[의존성: 마일스톤 5.1 잡]`
- [ ] MCP 도구 변경에 활동 로그 기록 연동 `[복잡도: M]` `[의존성: 마일스톤 5.1 잡, Phase 4]`
- [ ] 로그 기록 대상: 태스크 생성/이동/수정/삭제, 코멘트 추가, 체크리스트 체크, 칼럼 변경 `[복잡도: M]` `[의존성: 마일스톤 5.1 연동]`
- [ ] changes jsonb 구조 정의 (예: `{"board_column": ["Todo", "In Progress"]}`, `{"priority": ["low", "high"]}`) `[복잡도: S]` `[의존성: 마일스톤 5.1 잡]`

### 마일스톤 5.2: 활동 타임라인 뷰

- [ ] 라우트 정의: activity_logs (프로젝트 중첩), Admin 확장 라우트 (PRD 7절 참조) `[복잡도: S]` `[의존성: 마일스톤 5.1]`
- [ ] ActivityLogsController#index (프로젝트 범위, Pagy 페이지네이션) `[복잡도: M]` `[의존성: 마일스톤 5.2 라우트]`
- [ ] ActivityLogComponent (활동 항목 표시: 액터 아이콘/색상, 액션, 타임스탬프) `[복잡도: M]` `[의존성: 마일스톤 5.2 컨트롤러]`
- [ ] 보드 전체 타임라인 뷰 (사이드 패널 또는 별도 페이지) `[복잡도: M]` `[의존성: 마일스톤 5.2 컴포넌트]`
- [ ] 카드별 타임라인 (태스크 상세 뷰 내) `[복잡도: M]` `[의존성: 마일스톤 5.2 컴포넌트]`
- [ ] 사람/에이전트 시각 구분 (아이콘, 색상, 라벨) `[복잡도: S]` `[의존성: 마일스톤 5.2 컴포넌트]`

### 마일스톤 5.3: Admin 패널 확장

- [ ] Admin::ProjectsController (index, show — 전체 프로젝트 목록/상세) `[복잡도: M]` `[의존성: Phase 1]`
- [ ] Admin::ProjectKeysController (index — 전체 키 목록, 활성 상태 표시) `[복잡도: S]` `[의존성: Phase 1]`
- [ ] Admin 프로젝트 대시보드 (프로젝트별 태스크 수, 활성 키 수, 최근 활동) `[복잡도: M]` `[의존성: 마일스톤 5.3 컨트롤러]`
- [ ] 연결 모니터링: 키별 마지막 사용 시각, 사용 빈도 표시 `[복잡도: M]` `[의존성: 마일스톤 5.3 컨트롤러]`

### 마일스톤 5.4: Phase 5 테스트

- [ ] ActivityLogJob 단위 테스트 `[복잡도: S]` `[의존성: 마일스톤 5.1]`
- [ ] 활동 로그 기록 통합 테스트 (웹 UI + MCP 경로 모두) `[복잡도: M]` `[의존성: 마일스톤 5.1]`
- [ ] ActivityLogComponent 컴포넌트 테스트 `[복잡도: S]` `[의존성: 마일스톤 5.2]`
- [ ] Admin 컨트롤러 통합 테스트 `[복잡도: S]` `[의존성: 마일스톤 5.3]`
- [ ] i18n 추가: 활동 로그/Admin 관련 번역 (EN/KO) `[복잡도: S]` `[의존성: 없음]`

**기술 참고:**
- **활동 로그 패턴**: append-only 테이블이므로 `updated_at` 칼럼 없음. `readonly!` 또는 커스텀 콜백으로 수정/삭제 방지.
- **비동기 기록**: SolidQueue의 `ActivityLogJob.perform_later(...)` 으로 요청-응답 사이클을 차단하지 않는다.
- **Pagy 설정**: `pagy(:limit)` 사용 (`:items` 아님), `pagy(:slots)` 사용 (`:size` 아님). CLAUDE.md 참조.
- **activity_logs 보존 정책**: append-only 테이블이므로 시간이 지나면 데이터가 무한 증가한다. v1에서는 별도 정리 정책을 적용하지 않지만, 프로덕션 운영 후 데이터 증가 속도를 모니터링하고, 필요 시 90일 이상 된 로그를 별도 아카이브 테이블로 이동하는 SolidQueue 잡을 추가한다.

---

## Phase 6: 통합 테스트 & 배포 최적화 (예상 3-4일)

**목표:** 전체 시스템의 E2E 테스트를 보강하고, 성능/보안을 점검하며, 프로덕션 배포를 준비한다.

### 마일스톤 6.1: E2E 시스템 테스트

- [ ] 시스템 테스트: PRD 1.4절 전체 시나리오 (태스크 등록 -> 에이전트 이동 -> 코멘트 -> 체크리스트 -> 리뷰 -> 완료) `[복잡도: XL]` `[의존성: Phase 1-5 전체]`
- [ ] 시스템 테스트: 드래그앤드롭 (Capybara + headless Chrome) `[복잡도: L]` `[의존성: Phase 2-3]`
- [ ] 시스템 테스트: 실시간 동기화 (두 세션에서 보드 동시 조작) `[복잡도: L]` `[의존성: Phase 3]`
- [ ] 시스템 테스트: MCP 도구로 태스크 조작 -> 웹 UI 반영 확인 `[복잡도: L]` `[의존성: Phase 4]`

### 마일스톤 6.2: 성능 최적화

- [ ] N+1 쿼리 감사 (includes/preload 확인, strict_loading 활용) `[복잡도: M]` `[의존성: Phase 1-5]`
- [ ] 보드 뷰 쿼리 최적화 (BoardColumn + 태스크 + 라벨 eager loading) `[복잡도: M]` `[의존성: Phase 2]`
- [ ] 데이터베이스 인덱스 검증 (explain analyze) `[복잡도: S]` `[의존성: Phase 1]`
- [ ] Turbo Streams 브로드캐스트 페이로드 최소화 `[복잡도: S]` `[의존성: Phase 3]`

### 마일스톤 6.3: 보안 점검

- [ ] Brakeman 정적 분석 실행 및 경고 해소 `[복잡도: M]` `[의존성: Phase 1-5]`
- [ ] bundler-audit 실행 `[복잡도: S]` `[의존성: 없음]`
- [ ] importmap audit 실행 `[복잡도: S]` `[의존성: 없음]`
- [ ] MCP 엔드포인트 보안 검토 (인증 우회 테스트, 권한 에스컬레이션 테스트) `[복잡도: M]` `[의존성: Phase 4]`
- [ ] 프로젝트 키 보안 검토 (키 노출 방지, 해시 강도) `[복잡도: S]` `[의존성: Phase 1]`

### 마일스톤 6.4: 배포 준비

- [ ] Kamal 2 deploy.yml 업데이트 (환경변수 추가) `[복잡도: S]` `[의존성: 없음]`
- [ ] .kamal/secrets에 프로덕션 환경변수 추가 (MCP_ALLOWED_ORIGINS, PROJECT_KEY_SALT 등) `[복잡도: S]` `[의존성: 없음]`
- [ ] CI 파이프라인 업데이트 (신규 테스트 경로 포함: test/tools/, test/components/) `[복잡도: S]` `[의존성: 없음]`
- [ ] CSP report_only -> enforce 전환 및 정책 최종 검증 `[복잡도: M]` `[의존성: Phase 2-4 CSP 업데이트]`
- [ ] 프로덕션 seed 데이터 검토/제거 `[복잡도: S]` `[의존성: 없음]`
- [ ] README.md 업데이트 (새 기능 설명, MCP 연결 가이드) `[복잡도: M]` `[의존성: Phase 1-5]`
- [ ] 스모크 테스트: 스테이징 환경에서 전체 플로우 수동 확인 `[복잡도: M]` `[의존성: 마일스톤 6.4 배포 설정]`

**기술 참고:**
- **Capybara DnD 테스트**: SortableJS의 드래그앤드롭은 HTML5 Drag API가 아닌 자체 구현이므로, Capybara의 `drag_to`가 동작하지 않을 수 있다. `execute_script`로 SortableJS 이벤트를 직접 트리거하는 방식을 사용한다.
- **CI 시간 관리**: MCP Inspector 기반 통합 테스트는 CI에서 제외하고, 수동 검증 또는 별도 워크플로로 분리한다.

---

## 기술 결정 사항

### 1. fast-mcp 채택 (vs 공식 mcp 젬 vs 직접 구현)
**결정:** fast-mcp ~> 1.5 채택
**근거:** Rails Rack 미들웨어 통합, SSE + Streamable HTTP 지원, Dry::Schema 기반 인자 검증, 활발한 유지보수. 공식 mcp 젬은 아직 0.x (불안정)이며 Rails 통합 미흡. 직접 구현은 JSON-RPC 2.0 + SSE 트랜스포트 복잡도가 높아 비효율적.
**향후:** mcp 젬 1.0 안정화 시 전환 검토 (TSD 11.1절).

### 2. SortableJS 채택 (vs HTML5 Drag API 직접 구현)
**결정:** SortableJS 1.15 (Import Maps CDN 로드)
**근거:** 터치 지원, 애니메이션, 그룹 간 이동 기본 제공. Import Maps 호환. ~10KB gzip으로 경량. 젬이 아닌 JS 라이브러리이므로 젬 카운트 미포함.

### 3. Position 관리 (vs acts_as_list 젬)
**결정:** 직접 구현 (젬 미추가)
**근거:** Built-in First 철학. position 칼럼의 재정렬 로직은 단순하며, scope 기반 정렬만 필요. acts_as_list의 전체 기능이 필요하지 않음.

### 4. 소프트 삭제 (vs paranoia/discard 젬)
**결정:** 직접 구현 (`deleted_at` + 명시적 scope)
**근거:** Task 모델만 소프트 삭제 적용. `default_scope` 없이 `scope :active`를 명시적으로 사용하여 예기치 않은 동작 방지. v1에서는 복구 UI를 제공하지 않으며, 필요 시 DB 레벨(Rails 콘솔)에서 `deleted_at`을 nil로 설정하여 복구한다. 복구 UI는 향후 버전에서 추가 검토한다.

### 5. 활동 로그 기록 방식 (vs paper_trail 젬)
**결정:** 직접 구현 (append-only ActivityLog + SolidQueue 비동기)
**근거:** paper_trail은 모든 모델 변경을 자동 추적하지만, Guild Board는 특정 액션만 기록하고 사람/에이전트 구분이 필요. 커스텀 구현이 더 적합.

### 6. 프로젝트 키 인증 (vs fast-mcp 기본 인증 vs OAuth 2.1)
**결정:** 커스텀 프로젝트 키 인증 (fast-mcp authorize 블록 활용)
**근거:** MCP 스펙의 OAuth 2.1은 에이전트 연동에 과도함. 프로젝트 키 기반이 심플하고 보안 요구사항을 충족. bcrypt 해시 + 키별 권한 설정으로 충분.

### 7. BoardColumn 모델명 (vs Column)
**결정:** `BoardColumn` 모델명 사용 (테이블: `board_columns`)
**근거:** `Column`은 `ActiveRecord::ConnectionAdapters::Column`으로 이미 사용되는 클래스명이다. 직접적인 네임스페이스 충돌은 없지만, `Project.columns` 호출 시 ActiveRecord의 columns 메서드와 도메인 관계가 혼동될 수 있으며, 코드 검색 시 DB 칼럼인지 칸반 칼럼인지 구분이 어렵다. PRD/TSD에서는 `columns`로 정의되어 있으나, 구현 시 `BoardColumn`으로 변경한다.

### 8. MCP 라우트 방식 (Rack 미들웨어 vs PRD Api::McpController)
**결정:** fast-mcp Rack 미들웨어로 `/mcp` 경로에 마운트
**근거:** fast-mcp는 Rails 라우터를 거치지 않고 Rack 레벨에서 MCP 프로토콜을 처리한다. PRD 7절의 `namespace :api do namespace :mcp do ... end end` 라우트 구조와 `Api::McpController`는 사용하지 않는다. Rate Limit은 Rails 컨트롤러 레벨이 아닌 Rack 미들웨어 레벨 또는 fast-mcp의 before 훅에서 처리해야 한다.

---

## 참고 자료

### Rails 공식 문서
- [Action Cable Overview - Rails Guides](https://guides.rubyonrails.org/action_cable_overview.html)
- [ActionController::RateLimiting - Rails API](https://api.rubyonrails.org/classes/ActionController/RateLimiting/ClassMethods.html)
- [Turbo Streams Handbook](https://turbo.hotwired.dev/handbook/streams)

### Best Practice 참고
- [Building Real-time Apps with Rails 8, Hotwire & ActionCable in Production](https://dev.to/shettigarc/building-real-time-apps-with-rails-8-hotwire-actioncable-in-production-19fa)
- [Rails 8 introduces a built-in rate limiting API - BigBinary](https://www.bigbinary.com/blog/rails-8-rate-limiting-api)
- [Rails 8 Adds Ability To Use Multiple Rate Limits Per Controller - Saeloun](https://blog.saeloun.com/2024/11/25/rails-adds-ability-to-use-multiple-rate-limits-per-controller/)
- [Built-in Rate Limiting in Rails 8](https://dev.to/iarie/built-in-rate-limiting-in-rails-8-1hch)
- [Turbo Streams meets Action Cable](https://dev.to/ayushn21/turbo-streams-meets-action-cable-4poj)
- [Turbo Streams & Action Cable - Fly.io Docs](https://fly.io/docs/rails/the-basics/turbo-streams-and-action-cable/)

### 라이브러리 문서
- [fast-mcp GitHub Repository](https://github.com/yjacquin/fast-mcp) - Rails 통합, 도구 정의, 인증 방식
- [SortableJS GitHub Repository](https://github.com/SortableJS/Sortable) - 그룹 간 드래그앤드롭 설정
- [MCP Inspector](https://github.com/modelcontextprotocol/inspector) - MCP 서버 수동 검증 도구

---

## Quality Checklist

- [x] PRD v1.1의 모든 기능 요구사항 반영 (3.1~3.7)
- [x] TSD v1.0의 기술 스택 및 아키텍처 반영
- [x] 태스크 간 의존성이 올바르게 순서화됨 (순환 없음)
- [x] 각 Phase가 독립적으로 배포 가능
- [x] Rails 8.1 내장 기능 최대 활용 (rate_limit, Action Cable, Turbo Streams, SolidQueue/Cache/Cable)
- [x] 외부 젬 추가 최소화 (fast-mcp 1개만 추가, 총 5개)
- [x] 공식 문서와 best practice 검색 검증 완료
- [x] 보안 고려 (bcrypt 키 저장, Rate Limit, CSRF 면제, Origin 검증, CSP, Brakeman)
- [x] 성능 고려 (N+1 감사, 인덱스, 비동기 로깅, 페이지네이션, last_used_at 빈도 제한)
- [x] 테스트가 각 Phase에 포함됨 + 테스트 원칙 명시
- [x] i18n이 각 Phase에 포함됨
- [x] `BoardColumn` 모델명이 전체 ROADMAP에 일관 적용됨
- [x] 전체 일정 범위 및 크리티컬 패스 표기됨
- [x] 각 Phase에 라우트 정의 항목 포함됨
- [x] 소프트 삭제 복구 범위 명확화 (v1: DB 레벨만)
- [x] MCP 라우트 방식 기술 결정 기록됨
