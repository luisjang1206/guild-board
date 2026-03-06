# Design System Rules

> 이 문서는 프로젝트의 디자인 시스템 규칙을 정의합니다.
> CLAUDE.md에서 이 문서를 참조하여 모든 Claude Code 세션에서 일관된 디자인을 유지합니다.

---

## 1. 이중 디자인 시스템 (Dual Design System)

이 프로젝트는 **Admin 영역**과 **User 영역**에 서로 다른 디자인 시스템을 적용합니다.

| 영역 | 디자인 시스템 | 레이아웃 | 대상 |
|------|-------------|---------|------|
| **User** | Neo-Brutalism | `application.html.erb` | 일반 사용자가 보는 모든 페이지 |
| **Admin** | Modern UI (기본 Tailwind) | `admin.html.erb` | `Admin::` 네임스페이스 하위 페이지 |

---

## 2. User 영역 — Neo-Brutalism

`docs/DESIGN_GUIDE.md`의 원칙을 따릅니다. 핵심 규칙 요약:

### 필수 적용

- **보더**: `border-2 border-black` 이상 (최소 2px, 색상은 검정)
- **그림자**: `shadow-[4px_4px_0px_#000000]` (blur 0px 고정, 하드 쉐도우)
- **배경**: 고채도 단색 (그라데이션 절대 금지)
- **모서리**: `rounded-none` 기본 (border-radius 최대 8px)
- **호버**: `hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_#000000]`
- **액티브**: `active:translate-x-0.5 active:translate-y-0.5 active:shadow-[2px_2px_0px_#000000]`
- **텍스트**: `font-bold uppercase` (버튼, 배지, 라벨 등)

### 금지 사항

- `linear-gradient`, `radial-gradient`
- `box-shadow` blur 값 > 0 (`shadow-sm`, `shadow`, `shadow-md` 등)
- `border-radius` > 12px (`rounded-lg`, `rounded-xl`, `rounded-full`)
- `opacity` < 1 로 요소 흐리게 만들기
- `backdrop-filter: blur()` (glassmorphism)
- `border` 1px (`ring-1`, `border` without width)
- Neumorphism 스타일

### 권장 색상 팔레트

| 용도 | Tailwind 클래스 | Hex |
|------|----------------|-----|
| Primary 배경 | `bg-yellow-300` | `#FEF08A` |
| Secondary 배경 | `bg-lime-400` | `#A3E635` |
| Accent 핑크 | `bg-pink-400` | `#EC4899` |
| Accent 블루 | `bg-sky-300` | `#7DD3FC` |
| Accent 라벤더 | `bg-violet-300` | `#C4B5FD` |
| Neutral 배경 | `bg-amber-50` | `#FFF8E7` |
| 스트로크/텍스트 | `border-black text-black` | `#000000` |

### Tailwind 패턴 예시

```
/* 버튼 */
border-2 border-black bg-yellow-300 px-4 py-2 font-bold uppercase
shadow-[4px_4px_0px_#000000] transition-all
hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_#000000]
active:translate-x-0.5 active:translate-y-0.5 active:shadow-[2px_2px_0px_#000000]

/* 카드 */
border-2 border-black bg-white p-6 shadow-[4px_4px_0px_#000000]

/* 인풋 */
border-2 border-black bg-white px-3 py-2 shadow-[3px_3px_0px_#000000]
focus:shadow-[5px_5px_0px_#000000] focus:-translate-x-px focus:-translate-y-px outline-none

/* 배지 */
border-2 border-black bg-lime-400 px-2 py-0.5 text-xs font-bold uppercase
shadow-[2px_2px_0px_#000000]
```

---

## 3. Admin 영역 — Modern UI

기본 Tailwind CSS 스타일을 사용합니다. 기존 보일러플레이트의 컴포넌트 스타일을 유지합니다.

### 허용 스타일

- `rounded-md`, `rounded-lg` 등 둥근 모서리
- `shadow-sm`, `shadow` 등 부드러운 그림자
- `ring-1`, `border` 등 얇은 보더
- Indigo/Gray 팔레트 기반 색상 체계
- 표준 Tailwind 호버/포커스 상태

---

## 4. 영역 판별 기준

코드 작업 시 다음 기준으로 디자인 시스템을 선택합니다:

| 기준 | User (Neo-Brutalism) | Admin (Modern UI) |
|------|---------------------|-------------------|
| 컨트롤러 | `app/controllers/*.rb` | `app/controllers/admin/*.rb` |
| 뷰 | `app/views/*` (admin 제외) | `app/views/admin/*` |
| 레이아웃 | `application.html.erb` | `admin.html.erb` |
| 라우트 | `/*` | `/admin/*` |

### 공유 컴포넌트 처리

`app/components/`의 ViewComponent는 양쪽에서 사용될 수 있습니다:

- User 영역 전용 컴포넌트는 Neo-Brutalism 스타일로 작성
- Admin 영역 전용 컴포넌트는 Modern UI 스타일 유지
- 양쪽에서 공유하는 컴포넌트는 variant 파라미터로 스타일 분기

---

## 5. 참조 문서

- Neo-Brutalism 상세 가이드: `docs/DESIGN_GUIDE.md`
