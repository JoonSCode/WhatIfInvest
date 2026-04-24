# Stitch 전달 가이드

## 무엇을 보내면 되는가

Stitch에는 아래 순서로 주면 됩니다.

1. `design.md`
2. `screens.md`
3. `stitch-prompt.md`
4. 필요하면 `stitch-screen-instructions.md`

## 각 파일 역할

### `design.md`

앱 전반 규칙입니다.

- 어떤 원칙으로 텍스트가 안 넘치게 만들지
- 무엇을 절대 자르면 안 되는지
- 어떤 컴포넌트에서 어떤 구조를 써야 하는지

### `screens.md`

화면별 요구사항입니다.

- Explore
- Library
- Share Card
- Trust Notes
- Loading overlay

즉, Stitch가 화면마다 무엇을 바꿔야 하는지 보는 문서입니다.

### `stitch-prompt.md`

한 번에 붙여 넣는 요약 프롬프트입니다.

### `stitch-screen-instructions.md`

화면별로 더 세게 방향을 고정하고 싶을 때 추가로 주는 문서입니다.

## 전달 팁

- `overflow 대응`이라고 말하기보다 `overflow가 생기지 않게 레이아웃과 카피를 다시 설계`라고 요청하는 편이 맞습니다.
- `font를 줄여서 해결하지 말 것`을 꼭 같이 적어주세요.
- `금액, 수익률, 기간, disclaimer, freshness`는 절대 잘리지 않게 하라고 명시하는 게 중요합니다.
- `scenarioDescriptor 같은 긴 합성 문자열을 그대로 유지하지 말고 구조를 나눠라`는 점도 같이 전달하는 게 좋습니다.

## 권장 전달 문장

Use the attached documents to redesign WhatIfInvest so text does not overflow in English or Korean. The goal is overflow-proof layout and copy, not recovery after overflow. Change structure before changing font size.
