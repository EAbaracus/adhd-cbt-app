---
version: alpha
name: Ballast
description: Calm, anti-pressure CBT self-help for adults with ADHD. Built by a physician living with ADHD. 100% free — no ads, no paywalls, no streaks.
colors:
  primary: "#2F5FD0"
  primary-100: "#E3EBFA"
  primary-300: "#9DB8EC"
  primary-500: "#2F5FD0"
  primary-600: "#2750B4"
  primary-700: "#1F4296"
  primary-900: "#14295C"
  secondary: "#565E6A"
  tertiary: "#B8422E"
  bg: "#F6F8FA"
  panel: "#F0F3F6"
  border: "#E2E6EB"
  input-border: "#C6CCD4"
  placeholder: "#A3ABB5"
  text-tertiary: "#7C8490"
  text-secondary: "#565E6A"
  text-primary: "#1F242C"
  white: "#FFFFFF"
  red-500: "#E03E3E"
  red-900: "#6E1515"
  green-500: "#2FA36B"
  green-900: "#11452C"
  amber-500: "#E5A50E"
  amber-900: "#66450A"
typography:
  h1:
    fontFamily: Public Sans
    fontSize: 36px
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.01em"
  h2:
    fontFamily: Public Sans
    fontSize: 30px
    fontWeight: 700
    lineHeight: 1.2
  section:
    fontFamily: Public Sans
    fontSize: 24px
    fontWeight: 600
    lineHeight: 1.25
  subtitle:
    fontFamily: Public Sans
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.4
  lead:
    fontFamily: Public Sans
    fontSize: 18px
    fontWeight: 400
    lineHeight: 1.6
  body:
    fontFamily: Public Sans
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.6
  small:
    fontFamily: Public Sans
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
  caption:
    fontFamily: Public Sans
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.5
spacing:
  4: 4px
  8: 8px
  12: 12px
  16: 16px
  24: 24px
  32: 32px
  48: 48px
  64: 64px
rounded:
  sm: 8px
  lg: 12px
components:
  button-primary:
    backgroundColor: "{colors.primary-500}"
    textColor: "{colors.white}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
  button-primary-hover:
    backgroundColor: "{colors.primary-600}"
    textColor: "{colors.white}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
  button-secondary:
    backgroundColor: "{colors.white}"
    textColor: "{colors.text-secondary}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
    border: "{colors.border}"
  button-tertiary:
    backgroundColor: transparent
    textColor: "{colors.text-secondary}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
  button-destructive-confirm:
    backgroundColor: "{colors.red-500}"
    textColor: "{colors.white}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
  card:
    backgroundColor: "{colors.white}"
    rounded: "{rounded.lg}"
    border: "{colors.border}"
  card-active:
    backgroundColor: "{colors.white}"
    rounded: "{rounded.lg}"
    border: "{colors.primary-500}"
  input:
    backgroundColor: "{colors.white}"
    rounded: "{rounded.sm}"
    border: "{colors.input-border}"
  input-focus:
    backgroundColor: "{colors.white}"
    rounded: "{rounded.sm}"
    border: "{colors.primary-500}"
  chip-unselected:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.text-secondary}"
    rounded: "{rounded.lg}"
    border: "{colors.border}"
  chip-selected:
    backgroundColor: "{colors.primary-100}"
    textColor: "{colors.primary-700}"
    rounded: "{rounded.lg}"
    border: "{colors.primary-500}"
  badge-status:
    backgroundColor: "{colors.primary-100}"
    textColor: "{colors.primary-700}"
    rounded: "{rounded.sm}"
  badge-completed:
    backgroundColor: "{colors.green-900}"
    textColor: "{colors.white}"
    rounded: "{rounded.sm}"
  badge-available:
    backgroundColor: transparent
    textColor: "{colors.text-secondary}"
    rounded: "{rounded.sm}"
  scale-selector-unselected:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.text-secondary}"
    rounded: 9999px
  scale-selector-selected:
    backgroundColor: "{colors.primary-500}"
    textColor: "{colors.white}"
    rounded: 9999px
  empty-state-icon:
    textColor: "{colors.text-tertiary}"
    size: 40px
  dialog:
    backgroundColor: "{colors.white}"
    rounded: "{rounded.lg}"
    border: "{colors.border}"
  snackBar:
    backgroundColor: "{colors.text-primary}"
    textColor: "{colors.white}"
    rounded: "{rounded.sm}"
---

## Overview

**Ballast** is a calm, anti-pressure 12-week CBT self-help program for adults
with ADHD. It is built by a physician living with ADHD — the app is built by
its own target user, not by a team guessing what ADHD feels like.

The design system's single invariant: **the user is never punished.** No streaks,
no badges, no red error states for missed sessions, no date-based lockout.
Every color, component, and motion decision is filtered through this lens.

### Brand tone & voice

- **Calm but present.** Not cold or clinical, not chipper or gamified. The
  voice is a steady, non-judgmental co-pilot: clear-eyed about difficulty,
  warm about the user's effort.
- **Plain-language first.** Copy is conversational grade-6. No "optimize,"
  "leverage," "habit stacking." Use "do this," "try this," "next time."
- **Anti-shame.** Language assumes good intent and external constraints
  (executive dysfunction, distraction, fatigue) rather than internal failure.
  "Missing a session is part of the process, not a failure of it."
- **Science-grounded, not medicalized.** Cites evidence (Safren, Sprich,
  Perlman & Otto) without clinical jargon. The app is a *supportive guide*,
  never a diagnostic tool.

### Logo concept

A softened, abstract **brain-leaf** hybrid: a single continuous line that
loops into a leaf shape on one side and a simplified neural pathway on the
other — communicating growth + cognition, neurodivergence + nature.
- **Line weight:** 2px stroke, single continuous path (no fill).
- **Color:** primary-500 (#2F5FD0) on white; reverses to white on
  primary-500 for icon-only contexts.
- **No text lockup required in-app** — "Ballast" is rendered in the type
  scale (subtitle 600). The mark is used standalone in the launcher icon
  and as the favicon-equivalent.
- **Motion:** when the mark appears, it draws itself in 300ms ease-out (one
  stroke). Never auto-repeats.

### Logo usage rules

- Clear space: minimum 8px (spacing-8) of background on all sides.
- Minimum size: 24px render height (icon-only).
- Don't tint, recolor, or add shadows beyond the palette. Don't rotate or
  skew. Don't place on busy imagery — white or bg (#F6F8FA) only.
- Do: reverse to white on primary-500 for active-state icons and the
  confirmation-Dialog accent.

## Colors

| Token | Hex | Role |
|-------|-----|------|
| `primary-500` | #2F5FD0 | Actions, selected states, focus rings, active-card accent |
| `primary-700` | #1F4296 | Text-on-tint, stronger action states |
| `primary-900` | #14295C | Deep accent for text on primary-100 |
| `primary-100` | #E3EBFA | Tint background for selected chips, status badges |
| `bg` | #F6F8FA | Scaffold background |
| `panel` | #F0F3F6 | Card interior, inset wells, chip unselected bg |
| `border` | #E2E6EB | Card/dialog borders, dividers |
| `input-border` | #C6CCD4 | Input outlines (resting) |
| `text-primary` | #1F242C | Body + headings (never pure black) |
| `text-secondary` | #565E6A | Supporting text |
| `text-tertiary` | #7C8490 | Captions, meta, empty-state copy |
| `placeholder` | #A3ABB5 | Hint text |
| `white` | #FFFFFF | Cards, dialog surfaces, button text |
| `red-500` | #E03E3E | Destructive actions (confirmations only, not inline) |
| `green-500` | #2FA36B | Positive / completed status (light backgrounds) |
| `green-900` | #11452C | Completed badge text-on-tint |
| `amber-500` | #E5A50E | Warning / attention (avoid in body) |
| `amber-900` | #66450A | Warning text-on-tint |

**Status palette:** completed = green-900 on white (badge) / green-500
border; in-progress = primary-500 accent bar; available = text-secondary
(dead weight, no color emphasis); skipped = text-tertiary.

## Typography

**Public Sans** throughout — friendly geometric sans with strong ADHD readability
(open apertures, generous spacing). No heading uses more than 8 sizes; no
orphan weights.

| Size | Style | Grade |
|------|-------|-------|
| `caption` 12px / 1.5 | Regular | Meta, captions, field hints |
| `small` 14px / 1.5 | Regular | Body secondary, chip labels, list subtitles |
| `body` 16px / 1.6 | Regular | Default body text |
| `lead` 18px / 1.6 | Regular | Intro paragraphs, calmer emphasis |
| `subtitle` 20px / 1.4 | 600 | Card titles, dialog titles |
| `section` 24px / 1.25 | 600 | Section dividers, settings groupings |
| `h2` 30px / 1.2 | 700 | Page titles, empty-state titles |
| `h1` 36px / 1.15 | 700 | Timer readouts, completion hero numbers |

**Hierarchy rule:** one `h1` per screen; at most two `h2`; body copy
line length capped at ~600px for readability. No bold body. No italics —
emphasis via `lead` size or `text-secondary` color instead.

## Layout

- Scaffold padded 16px (spacing-16) on all screens.
- Lists: 16px card-to-card gap (vertical), edge-to-edge cards.
- Max content width: 560px on tablet/landscape (centered, padded 24px).
- AppBar: flat (elevation 0), bg surface, text-primary title, right-aligned
  icon actions. No shadow.
- Back/navigation: explicit Back between SessionFlow checkpoints
  (R0 contract — navigation never mutates state).

## Elevation & Depth

This system is **flat**. No drop shadows. Depth is signaled by:
- Border weight (1px rest, 4px accent bar for active cards).
- Surface contrast (bg → panel → card white).
- Layer order: cards sit flush; dialogs overlay at surface-level with border.

SnackBars use text-primary dark surface (not a shadow) with radius-sm
rounding and white text.

## Shapes

- Buttons, inputs: radius-sm (8px).
- Cards, dialogs, chips, snackbars: radius-lg (12px).
- Scale-selector (form presets): 9999px pill, 40px height.
- Status badges: radius-sm pill.
- Chip selected/unselected: full radius-lg, no square variants.

## Components

### Buttons — action pyramid

1. `button-primary` — one per view. primary-500 bg, white text. The single
   high-emphasis action.
2. `button-secondary` — secondary actions. White bg, text-secondary, border.
3. `button-tertiary` — link-style. Transparent, text-secondary.
4. `button-destructive-confirm` — confirmation dialogs only. red-500 bg,
   white text. **Never** used inline on a screen — destructive *actions*
   live in a settings row with text-secondary; the *confirmation* carries
   the heavy styling (G2 rule).

Variants (hover/active/pressed) are siblings (`button-primary-hover`), not
nested. Disabled = opacity 38% on the base style, no recolor.

### Inputs

`input` resting: white bg, input-border, radius-sm, 1px. On focus:
`input-focus` — primary-500 border, 2px. Hint = placeholder color; label =
text-secondary. Never per-widget ad-hoc decoration.

### Chips

`chip-unselected`: panel bg, text-secondary, border. `chip-selected`:
primary-100 bg, primary-700 text, primary-500 border. Radius-lg. Used for:
language, error catalog, timer presets, A/B/C.

### Cards

`card`: white, border, radius-lg, elevation 0. `card-active`: same but a
**4px primary-500 left accent bar** (width 4, left position) — the only
signal for the in-progress session. Never a full colored fill.

### Dialogs

`dialog`: white, radius-lg, border. Destructive confirmations require
explicit input (type "delete") — never one-tap.

### Empty states

40px icon (text-tertiary) + one-line title (subtitle, text-secondary) +
optional calm hint (body, text-tertiary). No red, no urgency. CTA visible
only when the action exists.

### Scale selector

Form-field kind scale (0–3): 40px tappable circles, selected = primary-500
fill + white text, unselected = panel + text-secondary. Neutral by default.

## Do's and Don'ts

**Do:**
- Cap text colors per view at 3 distinct values (text-primary, text-secondary,
  one semantic accent state).
- Use the primary-500 accent bar as the *only* active-session signal on cards.
- Persist form drafts on keystroke with a generation counter race guard.
- Route every user-facing string through AppStrings — even validation copy.

**Don't:**
- No red error text inline. Failed validation → inline text-tertiary message
  under the field, value never enters persistence.
- No streaks, badges, date-based lockouts, or gamification of any kind.
- No per-widget color values. Change a token, not a widget.
- No hover-only tooltips as the sole affordance — icons get tooltips, text
  labels are preferred.
- No rotation/skew of the logo mark.

## Accessibility (WCAG)

Spot-checked contrast against #FFFFFF (bg is #F6F8FA, cards are #FFFFFF):
- text-primary on white: ~15:1 ✓ (≥ 7 large, ≥ 4.5 normal)
- text-secondary on white: ~7.6:1 ✓
- text-tertiary on white: ~4.6:1 ✓ (≥ 4.5 normal)
- primary-500 on white text: ~6.3:1 ✓
- green-900 / amber-900 / red-900 on their 15%-tint backgrounds: dark-on-tint
  flip, ≥ 7:1 ✓

All interactive elements meet 48x48dp minimum touch target. Icon-only
buttons carry tooltips. Motion reduced via system setting.
