# Notion Documentation Guide

ForDay 프로젝트의 Notion 문서화 가이드입니다.

## Documentation Database

**CRITICAL**: All iOS development documentation should be written to the Notion database:

- **Database URL**: https://www.notion.so/devsoop/2f67a7b3ccf58007aa40e1b474dee03b
- **Database Name**: iOS 개발
- **Data Source ID**: `2f67a7b3-ccf5-8170-a13c-000b7b70cc41`

### Required Properties

| Property | Type | Description |
|----------|------|-------------|
| `Name` | title | Clear, descriptive title |
| `타입` | select | Documentation, Design, Bugfix, or Feature |
| `주제` | multi_select | Topics (see below) |
| `Status` | status | Not started, In progress, Done |
| `작업 날짜` | date | Work date |
| `설명` | text | Brief description |

### Available 주제 Options

온보딩, 디자인시스템, 초기세팅, 네트워킹, 문법, 클린아키텍처, 로컬DB, 디자인패턴, 내비게이션, UI, 메모리

**Note**: MCP 도구는 multi_select에 단일 값만 지원. 여러 주제가 필요하면 가장 대표적인 값 1개만 설정.

### When to Document

- Architectural decisions (e.g., Unidirectional Data Flow pattern)
- Repository organization changes
- Error handling patterns
- Complex bug fixes with architectural implications
- New design patterns introduced

### Documentation Format

- Problem description
- Root cause analysis
- Solution with code examples
- Key learning points
- List of affected files with line numbers

## Notion Page Content Format (Notion-flavored Markdown)

노션 페이지 콘텐츠 작성 시 아래 포맷을 사용. `notion://docs/enhanced-markdown-spec` 리소스를 매번 읽지 않아도 됨.

### 기본 블록

- `## Heading 2`, `### Heading 3` — 제목
- `- item` — 불릿 리스트
- `1. item` — 번호 리스트
- `---` — 구분선
- `> quote text` — 인용문 (멀티라인: `> line1<br>line2`)
- `- [ ] todo` / `- [x] done` — 체크리스트

### 리치 텍스트

- `**bold**`, `*italic*`, `~~strikethrough~~`, `` `code` ``
- `[Link text](URL)` — 링크
- `$Equation$` — 인라인 수식

### 코드 블록

````
```language
Code (do NOT escape special chars inside code blocks)
```
````

### 색상

`{color="Color"}` 블록 끝에 추가

- Text: gray, brown, orange, yellow, green, blue, purple, pink, red
- Background: gray_bg, brown_bg, orange_bg, yellow_bg, green_bg, blue_bg, purple_bg, pink_bg, red_bg

### 콜아웃

```
<callout icon="emoji" color="Color">
	Content
</callout>
```

### 테이블

```
<table header-row="true">
	<tr><td>Header 1</td><td>Header 2</td></tr>
	<tr><td>Data 1</td><td>Data 2</td></tr>
</table>
```

### 토글

```
▶ Toggle title
	Hidden content (must indent)
```

### 기타

- **멘션**: `<mention-page url="URL">Title</mention-page>`, `<mention-date start="YYYY-MM-DD"/>`
- **이미지/파일**: `<image source="URL">Caption</image>`, `<file source="URL">Caption</file>`
- **빈 줄**: `<empty-block/>` (일반 빈 줄은 제거됨)

### 주의사항

- 탭으로 들여쓰기
- `\ * ~ ` $ [ ] < > { } | ^` 문자는 백슬래시로 이스케이프
- 코드 블록 안에서는 이스케이프 하지 않음
- `<page url="...">` 사용 시 기존 페이지가 이동됨, 참조만 하려면 `<mention-page>` 사용
