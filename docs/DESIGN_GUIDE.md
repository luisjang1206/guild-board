# Neo-Brutalism 웹 디자인 프롬프트

> 이 문서는 Claude Code에게 neo-brutalism 스타일의 웹사이트를 요청할 때 사용하는 디자인 가이드이자 프롬프트입니다.
> CLAUDE.md에 포함시키거나, 프로젝트 시작 시 컨텍스트로 전달하세요.

---

## 프롬프트

아래의 **디자인 원칙**과 **CSS 규칙**을 준수하여 Neo-Brutalism 스타일의 웹사이트를 만들어줘.
모든 컴포넌트와 레이아웃은 이 문서에 정의된 원칙을 따라야 하며, 참조 리소스의 스타일을 벤치마크로 활용해.

---

## 1. Neo-Brutalism이란?

Neo-Brutalism(Neubrutalism)은 건축의 브루탈리즘에서 파생된 디지털 디자인 트렌드로,
날것의(raw) 미학과 현대적 사용성을 결합한 스타일이다.
미니멀리즘의 기능성은 유지하면서, 대담한 색상·타이포그래피·형태로 시각적 임팩트를 극대화한다.

### 핵심 철학

- **기능 우선 (Function over Form)**: 장식보다 사용성
- **솔직한 구조 (Honest Structure)**: UI 요소를 감추지 않고 그대로 노출
- **의도적 거칠음 (Intentional Rawness)**: 세련됨의 거부, 디지털 매체의 본질 표현
- **90년대 웹 향수 (Retro Nostalgia)**: Windows 98 스타일 버튼, 모노스페이스 폰트 등

---

## 2. 디자인 원칙

### 2.1 색상 (Color)

규칙:

- 고채도, 고대비 색상 조합 사용
- 그라데이션 절대 금지 → 단색(flat color)만 사용
- 검정(#000000)을 두려움 없이 사용 (스트로크, 그림자)
- 배경색은 흰색에 국한하지 않음 → 선명한 컬러 배경 적극 활용

#### 추천 팔레트

| 용도             | 색상        | Hex                  |
| ---------------- | ----------- | -------------------- |
| 배경 (Primary)   | 밝은 노랑   | `#FFD700`, `#FEF08A` |
| 배경 (Secondary) | 라임 그린   | `#A3E635`, `#BFFF00` |
| 배경 (Accent)    | 핫 핑크     | `#FF6B9D`, `#EC4899` |
| 배경 (Accent)    | 스카이 블루 | `#38BDF8`, `#7DD3FC` |
| 배경 (Accent)    | 라벤더      | `#C4B5FD`, `#A78BFA` |
| 배경 (Neutral)   | 크림/베이지 | `#FFF8E7`, `#FEFCE8` |
| 스트로크/텍스트  | 순수 검정   | `#000000`            |
| 그림자           | 순수 검정   | `#000000`            |

#### 색상 사용 규칙

- 배경: 섹션별로 다른 대담한 색상 사용 가능
- 텍스트: 기본은 #000000, 밝은 배경 위에서 가독성 확보
- 포인트 색상: 버튼, 카드 등 인터랙티브 요소에 대비되는 색상
- 절대 금지: linear-gradient, radial-gradient, opacity로 색상 흐리게 만들기

### 2.2 보더 & 스트로크 (Border & Stroke)

```css
/* 기본 보더 */
border: 2px solid #000000; /* 최소 2px, 권장 2-4px */

/* 강조 보더 */
border: 3px solid #000000; /* 카드, 버튼 등 주요 요소 */
border: 4px solid #000000; /* 히어로 섹션, 큰 요소 */
```

규칙:

- 최소 2px 두께: 1px 보더는 neo-brutalism에 어울리지 않음
- 색상은 검정(#000): 컬러 보더도 가능하지만 기본은 검정
- 모든 UI 요소에 보더 적용: 카드, 버튼, 인풋, 이미지 등
- border-radius 최소화: 0px 기본, 필요시 최대 8px

### 2.3 그림자 (Shadow)

```css
/* Neo-Brutalism 하드 쉐도우 — blur 없음! */
box-shadow: 4px 4px 0px #000000; /* 기본 */
box-shadow: 6px 6px 0px #000000; /* 중간 강조 */
box-shadow: 8px 8px 0px #000000; /* 강한 강조 */

/* 호버 시 그림자 이동 효과 */
.element:hover {
  transform: translate(-2px, -2px);
  box-shadow: 6px 6px 0px #000000;
}

.element:active {
  transform: translate(2px, 2px);
  box-shadow: 2px 2px 0px #000000;
}
```

규칙:

- blur 값은 반드시 0px: box-shadow의 세 번째 값
- spread도 0px: 단순하고 날카로운 그림자
- x, y 오프셋 동일: 대각선 방향 (보통 우하단)
- 그림자 색상: 기본 #000000, 컬러 그림자도 가능
- 인터랙션: 호버 시 그림자 확대 + 살짝 위로 이동, 클릭 시 그림자 축소 + 아래로 눌림

### 2.4 타이포그래피 (Typography)

```css
/* 추천 폰트 조합 */
--font-heading: "Space Grotesk", "DM Sans", "Inter", sans-serif;
--font-body: "Inter", "DM Sans", "Space Grotesk", sans-serif;
--font-mono: "Space Mono", "JetBrains Mono", monospace;

/* 한국어 포함 시 */
--font-heading: "Space Grotesk", "Pretendard", "Noto Sans KR", sans-serif;
--font-body: "Pretendard", "Noto Sans KR", sans-serif;

/* 크기 스케일 */
--text-hero: clamp(3rem, 8vw, 6rem); /* 히어로 타이틀 */
--text-h1: clamp(2rem, 5vw, 3.5rem); /* H1 */
--text-h2: clamp(1.5rem, 3vw, 2.5rem); /* H2 */
--text-h3: clamp(1.25rem, 2vw, 1.75rem); /* H3 */
--text-body: 1rem; /* 본문 16px */
--text-small: 0.875rem; /* 보조 14px */
```

규칙:

- 산세리프(sans-serif) 폰트 우선
- 제목은 크고 굵게 (font-weight: 700-900)
- 텍스트 자체가 장식 역할 → 화면을 꽉 채우는 큰 타이틀 적극 활용
- 모노스페이스 폰트로 레트로 느낌 강조 가능

### 2.5 형태 & 레이아웃 (Shape & Layout)

규칙:

- 직각 위주: border-radius는 0px 기본
- 비대칭 레이아웃 허용: 전통적 대칭에서 벗어남
- 원, 사각형, 별, 다각형 등 날것의 기하학적 도형 사용
- 요소 간 겹침(overlap) 활용 가능
- 여백(whitespace)은 의도적으로 넉넉하거나 극단적으로 좁게

### 2.6 일러스트레이션 & 이미지

규칙:

- 스트로크가 있는 단순한 일러스트레이션
- MS Paint 스타일의 가공되지 않은 그래픽
- 사진 사용 시 두꺼운 보더로 감싸기
- 스티커, 뱃지 스타일 그래픽 요소
- 절대 금지: 그라데이션 오버레이, 블러 효과, glassmorphism

---

## 3. 컴포넌트 CSS 레시피

### 3.1 버튼

```css
.btn-neo {
  padding: 12px 24px;
  font-size: 1rem;
  font-weight: 700;
  text-transform: uppercase;
  background: #ffd700;
  color: #000000;
  border: 3px solid #000000;
  border-radius: 0px;
  box-shadow: 4px 4px 0px #000000;
  cursor: pointer;
  transition: all 0.1s ease;
}

.btn-neo:hover {
  transform: translate(-2px, -2px);
  box-shadow: 6px 6px 0px #000000;
}

.btn-neo:active {
  transform: translate(2px, 2px);
  box-shadow: 2px 2px 0px #000000;
}
```

### 3.2 카드

```css
.card-neo {
  padding: 24px;
  background: #ffffff;
  border: 3px solid #000000;
  border-radius: 0px;
  box-shadow: 6px 6px 0px #000000;
}

/* 컬러 카드 변형 */
.card-neo--pink {
  background: #ff6b9d;
}
.card-neo--yellow {
  background: #fef08a;
}
.card-neo--blue {
  background: #7dd3fc;
}
.card-neo--green {
  background: #a3e635;
}
```

### 3.3 인풋

```css
.input-neo {
  padding: 12px 16px;
  font-size: 1rem;
  background: #ffffff;
  color: #000000;
  border: 3px solid #000000;
  border-radius: 0px;
  box-shadow: 3px 3px 0px #000000;
  outline: none;
}

.input-neo:focus {
  box-shadow: 5px 5px 0px #000000;
  transform: translate(-1px, -1px);
}
```

### 3.4 네비게이션 바

```css
.nav-neo {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 32px;
  background: #ffffff;
  border-bottom: 3px solid #000000;
}

.nav-neo__link {
  font-weight: 700;
  text-transform: uppercase;
  color: #000000;
  text-decoration: none;
  padding: 8px 16px;
  border: 2px solid transparent;
}

.nav-neo__link:hover {
  border: 2px solid #000000;
  background: #fef08a;
}
```

### 3.5 뱃지 / 태그

```css
.badge-neo {
  display: inline-block;
  padding: 4px 12px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  background: #a3e635;
  color: #000000;
  border: 2px solid #000000;
  box-shadow: 2px 2px 0px #000000;
}
```

---

## 4. Tailwind CSS 유틸리티 매핑

Tailwind를 사용할 경우 아래 클래스 조합으로 neo-brutalism을 구현할 수 있다.

```
/* 기본 카드 */
border-2 border-black shadow-[4px_4px_0px_#000000] bg-yellow-300

/* 버튼 */
border-2 border-black shadow-[4px_4px_0px_#000000] bg-pink-400
hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_#000000]
active:translate-x-0.5 active:translate-y-0.5 active:shadow-[2px_2px_0px_#000000]
transition-all font-bold uppercase

/* 인풋 */
border-2 border-black shadow-[3px_3px_0px_#000000] focus:shadow-[5px_5px_0px_#000000]
focus:-translate-x-px focus:-translate-y-px outline-none
```

```js
// tailwind.config.js 커스텀 설정 (선택)
module.exports = {
  theme: {
    extend: {
      boxShadow: {
        "neo-sm": "2px 2px 0px #000000",
        neo: "4px 4px 0px #000000",
        "neo-md": "6px 6px 0px #000000",
        "neo-lg": "8px 8px 0px #000000",
      },
      borderWidth: {
        3: "3px",
      },
      fontFamily: {
        heading: ["Space Grotesk", "sans-serif"],
        body: ["Inter", "sans-serif"],
        mono: ["Space Mono", "monospace"],
      },
    },
  },
};
```

---

## 5. 금지사항 체크리스트

아래 항목이 하나라도 포함되면 neo-brutalism이 아니다:

| 금지 항목                             | 이유                                          |
| ------------------------------------- | --------------------------------------------- |
| `linear-gradient` / `radial-gradient` | 그라데이션은 neo-brutalism의 flat 원칙에 위배 |
| `box-shadow`에 blur 값 > 0            | 하드 쉐도우만 허용 (blur: 0px 고정)           |
| `border-radius` > 12px                | 둥근 모서리는 스타일 정체성을 해침            |
| `opacity` < 1 로 요소 흐리게          | 모든 요소는 선명하고 솔직해야 함              |
| `backdrop-filter: blur()`             | glassmorphism 요소 금지                       |
| `border: 1px`                         | 최소 2px, 존재감 있는 보더 필수               |
| Neumorphism 스타일 그림자             | 부드러운 양각/음각 효과 금지                  |
| 과도한 애니메이션                     | 간결한 hover/active 전환만 허용               |
| 장식적 그라데이션 배경                | 단색 배경만 사용                              |

---

## 6. 참조 리소스

### 스타일 가이드 & 아티클

| 리소스                          | URL                                                                                   | 설명                                                 |
| ------------------------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| NN/g (Nielsen Norman Group)     | https://www.nngroup.com/articles/neobrutalism/                                        | UX 관점의 정의, 모범사례, 접근성 고려사항            |
| Sepideh Yazdi 치트시트 (Medium) | https://medium.com/@sepidy/how-can-i-design-in-the-neo-brutalism-style-d85c458042de   | 색상, 타이포, 쉐도우, 형태 등 체계적 정리 + 치트시트 |
| Sepideh Yazdi (Behance)         | https://www.behance.net/gallery/164728311/How-can-I-design-in-the-Neo-Brutalism-style | 비주얼 중심 가이드, 실제 디자인 예시 풍부            |
| Bejamas 가이드                  | https://bejamas.com/blog/neubrutalism-web-design-trend                                | 역사, 원칙, 타이포그래피, 색상 심층 분석             |
| Alpha Efficiency 가이드         | https://alphaefficiency.com/neo-brutalism-web-design                                  | 실무 적용 관점의 상세 해설                           |

### 컴포넌트 라이브러리 (복사/붙여넣기 가능)

| 라이브러리               | URL                                           | 기술 스택                                  |
| ------------------------ | --------------------------------------------- | ------------------------------------------ |
| neobrutalism.dev         | https://www.neobrutalism.dev/                 | shadcn/ui + Tailwind CSS                   |
| Neo-Brutalism UI Library | https://neo-brutalism-ui-library.vercel.app/  | React + Tailwind CSS                       |
| RetroUI                  | https://www.retroui.dev/                      | React + Tailwind CSS                       |
| NeoBrutalismCSS          | https://matifandy8.github.io/NeoBrutalismCSS/ | 순수 CSS 프레임워크 (npm: neobrutalismcss) |

### 큐레이션 & 영감

| 리소스               | URL                                                  | 설명                                          |
| -------------------- | ---------------------------------------------------- | --------------------------------------------- |
| Awesome-Neobrutalism | https://github.com/ComradeAERGO/Awesome-Neobrutalism | 사이트 예시, Figma Kit, 아이콘, 튜토리얼 모음 |
| HubSpot 가이드       | https://blog.hubspot.com/website/neo-brutalism       | 사용 시기/피해야 할 상황 판단 기준            |

---

## 7. 사용 예시

### 기본 요청

```
이 프로젝트는 neo-brutalism 스타일을 따른다.
neo-brutalism-prompt.md를 참조하여 모든 UI를 구현해줘.
지금 랜딩 페이지를 만들어줘.
```

### 특정 컴포넌트 요청

```
neo-brutalism-prompt.md의 디자인 원칙을 따라서
프라이싱 카드 3개를 만들어줘.
각 카드는 다른 배경색(노랑, 핑크, 라임)을 사용하고
하드 쉐도우와 두꺼운 보더를 적용해.
```
