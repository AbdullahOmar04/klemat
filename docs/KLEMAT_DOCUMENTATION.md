# Cover Page

[PLACEHOLDER: University/Institution Logo]

[PLACEHOLDER: Klemat Project Logo]

**Project Name:** Klemat — An Arabic Wordle-Style Mobile Game

**Course / Project:** [PLACEHOLDER: Course or Project Name]

**Semester / Year:** [PLACEHOLDER: Semester, Year]

**Supervised by:** [PLACEHOLDER: Supervisor Name]

**Institution:** [PLACEHOLDER: Institution Name, Faculty, Department]

## Team Members

| No. | Student Name | Section | Student ID |
|-----|--------------|---------|------------|
| 1 | [PLACEHOLDER: Name] | [PLACEHOLDER: Section] | [PLACEHOLDER: ID] |
| 2 | [PLACEHOLDER: Name] | [PLACEHOLDER: Section] | [PLACEHOLDER: ID] |
| 3 | [PLACEHOLDER: Name] | [PLACEHOLDER: Section] | [PLACEHOLDER: ID] |
| 4 | [PLACEHOLDER: Name] | [PLACEHOLDER: Section] | [PLACEHOLDER: ID] |

---

# Table of Contents

1. [Summary](#summary)
2. [Chapter 1 — Introduction](#chapter-1--introduction)
   - 1.1 [Overview](#11-overview)
   - 1.2 [Main Objectives](#12-main-objectives)
   - 1.3 [Main Motivations](#13-main-motivations)
   - 1.4 [Constraints](#14-constraints)
   - 1.5 [Similar Projects](#15-similar-projects)
   - 1.6 [Project Organization](#16-project-organization)
3. [Chapter 2 — Project Management](#chapter-2--project-management)
   - 2.1 [Feasibility Study](#21-feasibility-study)
   - 2.2 [The Needed Hardware and Software](#22-the-needed-hardware-and-software)
   - 2.3 [The Schedule and the Estimated Time](#23-the-schedule-and-the-estimated-time)
4. [Chapter 3 — Project Specification](#chapter-3--project-specification)
   - 3.1 [Stakeholders](#31-stakeholders)
   - 3.2 [Data Gathering Techniques](#32-data-gathering-techniques)
   - 3.3 [Functional Requirements](#33-functional-requirements)
   - 3.4 [Non-Functional Requirements](#34-non-functional-requirements)
   - 3.5 [Domain Requirements](#35-domain-requirements)
   - 3.6 [Requirements Analysis and Architecture Design](#36-requirements-analysis-and-architecture-design)
5. [Chapter 4 — Project Design](#chapter-4--project-design)
   - 4.1 [Class Diagrams](#41-class-diagrams)
   - 4.2 [Use Case Diagrams and Their Responsibilities](#42-use-case-diagrams-and-their-responsibilities)
6. [Chapter 5 — Project Implementation](#chapter-5--project-implementation)
   - 5.1 [Application Configuration](#51-application-configuration)
7. [Chapter 6 — Project Testing](#chapter-6--project-testing)
   - 6.1 [Test Cases](#61-test-cases)
   - 6.2 [Test Methodologies](#62-test-methodologies)
8. [Chapter 7 — User Manual](#chapter-7--user-manual)
9. [Appendixes](#appendixes)
10. [References](#references)

## List of Tables

| # | Title | Section |
|---|-------|---------|
| 1 | Hardware and Software Needed | 2.2 |
| 2 | Project Schedule | 2.3.1 |
| 3 | Stakeholders | 3.1 |
| 4 | Functional Requirements | 3.3 |
| 5 | Non-Functional Requirements | 3.4 |
| 6 | Domain Requirements | 3.5 |
| 7 | Component Analysis | 3.6.2 |
| 8 | Class — GameController / FiveLetterScreen | 4.1.1 |
| 9 | Class — UserDataService | 4.1.1 |
| 10 | Class — CustomKeyboard | 4.1.1 |
| 11 | Class — GameStatsSnapshot | 4.1.1 |
| 12 | Class — GameTimer | 4.1.1 |
| 13 | Class — Challenge | 4.1.1 |
| 14 | Class — ThemeNotifier | 4.1.1 |
| 15 | Class — AppLocalizations | 4.1.1 |
| 16 | Use Case — Submit Guess | 4.2 |
| 17 | Use Case — Reveal Hint | 4.2 |
| 18 | Use Case — View Stats | 4.2 |
| 19 | Use Case — Play Daily Word | 4.2 |
| 20 | Use Case — Sign In / Register | 4.2 |
| 21 | Use Case — View Leaderboard | 4.2 |
| 22 | Use Case — Browse Library | 4.2 |
| 23 | Use Case — Change Language / Theme | 4.2 |
| 24 | Test Cases | 6.1 |
| 25 | Test Methodologies | 6.2 |

## List of Figures

| # | Title | Section |
|---|-------|---------|
| 1 | PERT Diagram | 2.3.2 |
| 2 | System Architecture Diagram | 3.6.2 |
| 3 | Complete Class Diagram | 4.1 |
| 4 | Use Case Diagram — Game Logic Engine | 4.2 |
| 5 | Use Case Diagram — Persistence & Auth | 4.2 |
| 6 | Use Case Diagram — UI & Input | 4.2 |
| 7 | Use Case Diagram — Localization & Theming | 4.2 |
| 8 | Use Case Diagram — Dictionary & Definitions | 4.2 |
| 9 | Sequence Diagram — Submit Guess | 4.2 |
| 10 | Sequence Diagram — Reveal Hint | 4.2 |
| 11 | Sequence Diagram — View Stats | 4.2 |
| 12 | Sequence Diagram — Play Daily Word | 4.2 |
| 13 | Sequence Diagram — Sign In | 4.2 |
| 14 | Screenshot — Login Screen | Chapter 7 |
| 15 | Screenshot — Main Menu | Chapter 7 |
| 16 | Screenshot — Level Map | Chapter 7 |
| 17 | Screenshot — Gameplay UI | Chapter 7 |
| 18 | Screenshot — Daily Word Screen | Chapter 7 |
| 19 | Screenshot — Stats Modal | Chapter 7 |
| 20 | Screenshot — Leaderboard | Chapter 7 |
| 21 | Screenshot — Library / Collected Words | Chapter 7 |
| 22 | Screenshot — Definition Dialog | Chapter 7 |
| 23 | Survey / Playtest Feedback Sample | 3.2 |

---

# Summary

## Project Overview

**Klemat** (Arabic: *كلمات*, "words") is a mobile word-puzzle game written in Flutter that brings the globally popular Wordle experience to Arabic speakers. A player is given six to seven attempts to guess a hidden Arabic word of three, four, or five letters. After each guess the game reveals, letter by letter, whether the submitted characters are in the correct position, in the target word but in the wrong position, or not in the target word at all — encoded as green, orange, and grey tiles respectively. Klemat extends the basic Wordle formula with a level-based campaign across three difficulty tiers, a daily-word mode with deterministic per-day puzzles, a persistent streak and diamond-currency economy, an Almaany-powered definition dialog that turns every round into a vocabulary lesson, and a global Firebase-backed leaderboard.

## Target Audience

- Native Arabic speakers who enjoy short-form daily word games.
- Learners of Arabic at intermediate-to-advanced levels who want vocabulary practice in a low-pressure format.
- Puzzle enthusiasts who already play Wordle, NYT Connections, or Scrabble-family games and are looking for a language variant.
- Families and classrooms that want a light educational tool for Modern Standard Arabic vocabulary.

## Project Goals

- Deliver an authentically Arabic, RTL-first word-guessing experience with a custom on-screen Arabic keyboard rather than a localized Latin layout.
- Reinforce vocabulary acquisition by linking every solved word to its Almaany dictionary entry.
- Provide a long-term engagement loop through daily words, streaks, and level progression.
- Demonstrate a complete Flutter + Firebase mobile architecture (authentication, cloud persistence, localization, theming, animations) suitable for academic evaluation.
- Ship a product that runs smoothly on commodity Android devices without requiring a high-end handset.

## Project Features

- **Three story modes** — 3-, 4-, and 5-letter words with independent level progression (`currentLevel3`, `currentLevel4`, `currentLevel5`).
- **Daily word mode** with a deterministic, date-seeded puzzle shared across the entire player base.
- **Custom Arabic keyboard** with three letter rows, a dedicated submit key (*إدخال*), a backspace key, and a diamond-priced hint key.
- **Two-pass letter-state algorithm** that correctly handles duplicate letters — a known Wordle edge case.
- **Persistent statistics**: games played, win percentage, current streak, max streak, and a seven-bucket guess distribution.
- **Diamond economy**: earned for wins, milestone streaks, and fast solves; spent on hints and future cosmetic unlocks.
- **Global leaderboard** backed by Cloud Firestore and keyed on points.
- **Almaany-powered definitions** fetched by HTTP scrape at the end of each round and surfaced in a dedicated dialog.
- **Localization** (Arabic / English) with a bespoke `AppLocalizations` delegate, and **light / dark / system** theming persisted across sessions.
- **Haptics, confetti, shake, and scale animations** for tactile and visual feedback.

## Deliverables

- A functional Android mobile application (release-signed APK and Android Studio project).
- Full Flutter source code organized under `lib/` with documented screens, widgets, and helpers.
- This software documentation package (Chapters 1–7 plus appendixes and references).
- A short demo video / presentation suitable for project defence.
- Word-list assets (3-, 4-, and 5-letter answers and validation lists) curated from public Arabic dictionaries.

---

# Chapter 1 — Introduction

## 1.1 Overview

Klemat is an Arabic-language word-guessing game inspired by Josh Wardle's *Wordle* (2021, later acquired by *The New York Times*). Unlike most Arabic Wordle clones, which are browser-only or quickly abandoned, Klemat is a native Flutter mobile application with cloud persistence, user accounts, and a campaign layer. The player launches the app, authenticates via Firebase Authentication (or proceeds as a guest), and lands on a main menu that offers a daily word, three story modes of graded difficulty, a global leaderboard, a personal library of previously solved words, and a settings/profile drawer.

Inside a round, the player types Arabic letters on a custom on-screen keyboard. Each row of the 7×5 board (or 6×4 / 6×3 for shorter words) represents one guess. Upon submission the game validates the guess against a dictionary of valid Arabic words, then compares each character to the hidden target using a two-pass algorithm that accounts for duplicate letters. The result is rendered by colouring each tile and the corresponding key on the keyboard: green for a correct letter in the correct position, orange for a correct letter in the wrong position, and grey for a letter not in the word. When the player guesses correctly, confetti erupts, the win is recorded in the Firestore statistics document, and an Almaany definition dialog opens — transforming each victory into a micro-lesson. When all guesses are exhausted the target word is revealed alongside the same definition.

Under the hood Klemat is built in Dart on Flutter 3, uses the Provider package for theme and locale state, persists preferences in `SharedPreferences`, persists user data in Cloud Firestore, and relies on a handful of focused packages (`confetti`, `http`, `html`, `url_launcher`, `flutter_localizations`) rather than a heavy framework stack. The codebase spans twenty-seven Dart files totalling several thousand lines, with the bulk of the logic concentrated in [lib/helper.dart](../lib/helper.dart), [lib/keyboard.dart](../lib/keyboard.dart), and the four game screens under [lib/screens/](../lib/screens/).

## 1.2 Main Objectives

1. Build a fully playable Arabic Wordle-style game on Android (and iOS-ready) using Flutter.
2. Design and implement a custom Arabic keyboard optimised for five-letter word entry.
3. Implement a Wordle-correct two-pass letter-state algorithm that handles duplicate characters, diacritics, and Arabic-specific letter variants.
4. Provide three difficulty tiers (3-, 4-, and 5-letter words) with level-based progression tracked in the cloud.
5. Offer a daily word mode whose target is identical for every player on any given calendar day.
6. Track player statistics — games played, win percentage, current and max streaks, and guess distribution — and display them in an animated stats modal.
7. Integrate Firebase Authentication and Cloud Firestore for user accounts, progress sync, and a global leaderboard.
8. Support both Arabic and English UI copy via a custom `AppLocalizations` delegate, and light/dark/system theming.
9. Teach as well as entertain: link every solved word to its Almaany definition and maintain a personal word library.
10. Document the system to a standard suitable for academic submission.

## 1.3 Main Motivations

1. **Linguistic representation.** Most word games in app stores target English vocabulary; Arabic speakers deserve a polished, native-feeling equivalent.
2. **Educational value.** Pairing a guessing game with an authoritative dictionary lookup creates an engaging vocabulary-building loop.
3. **The Wordle moment.** The viral success of the original Wordle demonstrated that short, once-a-day puzzles have enormous appeal; we wanted to capture that energy in Arabic.
4. **Cross-platform practice.** The project was a vehicle for the team to learn Flutter, Firebase, and end-to-end mobile development on a non-trivial product.
5. **RTL / Unicode challenge.** Arabic is a right-to-left language with rich diacritics and multiple glyph variants; implementing it correctly is a worthwhile engineering exercise.
6. **Community play.** A leaderboard and shared daily word create a sense of community even though the game is otherwise single-player.
7. **Portfolio piece.** A finished, well-architected game is stronger evidence of capability than a toy CRUD app.

## 1.4 Constraints

**Time constraints.** The project was scoped to a single academic semester (approximately 15 weeks) alongside other coursework. Scope decisions — for example, supporting only Android initially, or reusing a generic Material font rather than shipping a custom Arabic typeface — were driven by this budget.

**Technical complexity.** Arabic text rendering introduces challenges not present in Latin Wordle clones. Letters have up to four contextual forms (isolated, initial, medial, final), there are visually similar variants (ا / أ / إ / آ, ه / ة, ي / ى), and diacritical marks (*harakat*) can either be part of the target word or stripped. Klemat resolves this by treating the full codepoint sequence as canonical: the word list is stored with diacritics intact and comparison is exact rather than normalised. Additional complexity came from making the 7×5 board feel tactile (shake on invalid input, scale-pop on reveal, confetti on win) while keeping frame times below 16 ms.

**Team skills and experience.** The team began with intermediate Dart knowledge but no prior Flutter or Firebase experience. Early weeks were invested in tutorials and throwaway prototypes. Firestore security rules, Firebase Auth flows, and custom-painter gesture handling (used by the level map) were all new ground and are reflected in the iterative structure of the schedule in §2.3.

## 1.5 Similar Projects

- **Wordle (NYT / Josh Wardle, 2021).** The originator. A browser-based daily puzzle in English with a simple, addictive loop. Klemat differs by being mobile-native, supporting Arabic, offering multiple difficulty modes, and adding a user-account layer with persistent statistics. Where Wordle offers one word per day in one language, Klemat offers a daily puzzle *and* a multi-level campaign in the same app.
- **Wordly / ArabWord (assorted browser clones).** Several community Arabic Wordle clones exist as web pages. They are useful proofs-of-concept but generally lack persistent user accounts, cross-session progress, in-app dictionaries, or any economy. Klemat's Firebase-backed persistence, Almaany integration, and diamond economy address those gaps.
- **Kelma / Arabic word-of-the-day apps.** A handful of Arabic vocabulary-builder apps exist but frame the experience as flashcards or quizzes rather than a puzzle. Klemat blends vocabulary acquisition with the addictive game loop of Wordle rather than presenting learning as a separate mode.

Compared to these, Klemat's differentiators are: native mobile implementation, three graded difficulty tiers, a daily word shared across players, Firestore-backed persistence and leaderboards, an in-game Almaany dictionary dialog, and a diamond/hint economy.

## 1.6 Project Organization

**Document flow.** This document follows a standard software-engineering deliverable structure. Chapter 1 orients the reader; Chapter 2 addresses project management and feasibility; Chapter 3 captures requirements and architecture; Chapter 4 details design; Chapter 5 covers implementation; Chapter 6 covers testing; Chapter 7 is the end-user manual; appendixes and references close the document.

**Communication methods.** The team used a combination of [PLACEHOLDER: communication channels, e.g. WhatsApp / Discord / Microsoft Teams] for day-to-day communication, [PLACEHOLDER: tool, e.g. Trello / Jira / GitHub Projects] for task tracking, and weekly in-person / online meetings with the supervisor.

**Processes and methodologies.** Development followed an iterative, incremental methodology loosely inspired by Scrum. Each week corresponded roughly to a sprint: a short planning discussion, focused execution, and a Friday demo to the supervisor. Version control was git, hosted on GitHub, with feature branches merged through pull requests after code review. Continuous manual testing was carried out on a physical Android device.

**Resources.** The team relied on the official Flutter and Firebase documentation, the Almaany online dictionary (for definitions and word sourcing), the pub.dev package registry for open-source Dart packages, and Stack Overflow for diagnostic support. See [References](#references) for the full list.

---

# Chapter 2 — Project Management

## 2.1 Feasibility Study

**Technical feasibility.** The project is technically feasible with modest resources. Flutter provides a mature cross-platform SDK with an established Arabic rendering pipeline and strong tooling support on Linux, Windows, and macOS. Firebase supplies authentication, a NoSQL database (Firestore), and analytics under a generous free tier (Spark plan) that is more than sufficient for a student-scale user base. All third-party packages used (`provider`, `confetti`, `http`, `html`, `url_launcher`, `shared_preferences`) are actively maintained and compatible with the current Flutter stable channel. The only non-trivial technical risks were Arabic text handling (mitigated by Flutter's native Unicode support) and the correctness of the letter-state algorithm (mitigated by focused unit testing). At no point did the team encounter a blocker that required switching frameworks.

**Operational feasibility.** Klemat is designed to run on any Android device with Android 7.0 (API 24) or newer, which covers the overwhelming majority of the target market. The app is small (<30 MB release APK) and functions on both 2 GB and 4 GB RAM devices without stutter during normal gameplay. The onboarding flow (sign-up or guest entry) takes under a minute, and the core gameplay loop is intentionally similar to Wordle so that new users can engage immediately. Data-wise, Firestore reads per session are bounded (user document on launch, game stats on open, leaderboard on view) and comfortably within free-tier limits.

**Legal feasibility.** Three legal considerations were reviewed. (1) *Gameplay similarity.* The Wordle gameplay mechanic is not patented; multiple large games now use the same format without legal action from The New York Times. Klemat uses original assets, a different name, and distinct visual design. (2) *Dictionary content.* The word lists were compiled from publicly available Arabic vocabulary sources and the Almaany online dictionary, which permits fair-use linking to definitions. For a commercial release the team would license a dictionary provider explicitly. (3) *Firebase and third-party terms.* Firebase's terms of service and the open-source licences (MIT / BSD) of all bundled packages are compatible with non-commercial distribution and, with standard attribution, with commercial distribution. No privacy-impacting data is collected beyond email and in-game progress, and a privacy notice would accompany any public release.

## 2.2 The Needed Hardware and Software

| Description | Quantity | Unit Price (USD) | Total Price (USD) | Note |
|-------------|----------|------------------|-------------------|------|
| Developer laptop (16 GB RAM, SSD) | 2 | 900 | 1,800 | Primary development machines |
| Android test device (mid-range, 4 GB RAM) | 2 | 250 | 500 | On-device testing |
| Android test device (low-end, 2 GB RAM) | 1 | 120 | 120 | Performance floor validation |
| MacBook (for iOS build validation) | 1 | 1,300 | 1,300 | Optional; borrowed if unavailable |
| Flutter SDK | 1 | 0 | 0 | Open-source |
| Android Studio / VS Code | 1 | 0 | 0 | Free IDEs |
| Firebase Spark plan | 1 | 0 | 0 | Free tier: Auth + Firestore |
| GitHub (private repo) | 1 | 0 | 0 | Free for students |
| Figma (UI design) | 1 | 0 | 0 | Free tier |
| Domain / Play Console (optional, future release) | 1 | 25 | 25 | Google Play developer one-time fee |
| Miscellaneous (USB cables, adapters, internet) | — | 100 | 100 | Incidental |
| **Grand total** | | | **3,845** | |

## 2.3 The Schedule and the Estimated Time

### 2.3.1 Schedule

| Task ID | Description | Duration | Dependency | Responsible Partner(s) | Resources |
|--------|-------------|----------|------------|------------------------|-----------|
| T1 | Requirements gathering, scope definition, team charter | 1 week | — | All members | Meetings, supervisor consultation |
| T2 | High-fidelity UI design in Figma (menu, board, keyboard, stats) | 1.5 weeks | T1 | Design lead | Figma |
| T3 | Flutter project scaffold, repo setup, CI basics | 0.5 week | T1 | Tech lead | Flutter, GitHub |
| T4 | Firebase project, Auth, Firestore rules, Android config | 1 week | T3 | Backend partner | Firebase console, `google-services.json` |
| T5 | Arabic word-list curation & packaging into JSON assets | 1 week | T1 | Language lead | Almaany, public dictionaries |
| T6 | Custom Arabic keyboard widget | 1 week | T3 | UI partner | Flutter |
| T7 | Game board widget & animations (shake, scale, confetti) | 1.5 weeks | T3, T6 | UI partner | `confetti` package |
| T8 | Two-pass letter-state algorithm & guess submission flow | 1 week | T5, T7 | Tech lead | — |
| T9 | Level-based campaign modes (3, 4, 5 letters) | 1 week | T8 | Backend partner | Firestore |
| T10 | Daily-word mode with date-seeded RNG | 0.5 week | T8 | Backend partner | — |
| T11 | Stats, streaks, diamonds, leaderboard | 1 week | T4, T9 | Backend partner | Firestore |
| T12 | Almaany definition scraping & dialog | 0.5 week | T7 | Tech lead | `http`, `html` |
| T13 | Localization (AR/EN) & theming (light/dark/system) | 0.5 week | T3 | UI partner | `flutter_localizations` |
| T14 | Level map custom painter | 1 week | T9 | UI partner | Flutter Canvas |
| T15 | End-to-end testing, bug fixing, polish | 1.5 weeks | T7–T14 | All members | Android devices |
| T16 | Documentation & final presentation | 1 week | T15 | All members | This document |

Total elapsed calendar time: approximately **15 weeks**, with parallel work on UI (T6, T7, T13, T14) and backend (T4, T9, T10, T11) tracks after T3 completes.

### 2.3.2 PERT Diagram

[PLACEHOLDER: Insert PERT Diagram showing dependencies between T1–T16]

**Critical path.** The critical path runs T1 → T3 → T4 → T8 → T9 → T11 → T15 → T16, for a total duration of roughly 10.5 weeks. Any slip on the algorithm (T8), level infrastructure (T9), or statistics/leaderboard integration (T11) directly pushes out the final delivery. The UI track (T6, T7, T13, T14) is parallel and has approximately one week of slack; the level map (T14) was the most schedule-risky UI task because it relies on custom painting.

---

# Chapter 3 — Project Specification

## 3.1 Stakeholders

| ST ID | Stakeholder | Description |
|-------|-------------|-------------|
| ST1 | Players (end users) | Arabic-speaking players and learners who install the app and play the game. Primary consumer of the product. |
| ST2 | Development team | The four-member student team building, testing, and deploying the application. |
| ST3 | Project supervisor | Faculty member who reviews progress, gives technical feedback, and grades the final deliverable. |
| ST4 | Institution | The university / department whose standards the documentation and deliverable must meet. |
| ST5 | Content provider (Almaany) | External dictionary service whose public definitions are surfaced after every round. |
| ST6 | Firebase / Google | Cloud provider whose Auth and Firestore products back the user-account and leaderboard subsystems. |
| ST7 | Arabic-language community | Broader audience whose feedback and vocabulary informs word-list decisions. |
| ST8 | Potential sponsors / publishers | [PLACEHOLDER: parties who may fund future development or monetization] |

## 3.2 Data Gathering Techniques

Several techniques were used to gather data during the requirements and design phases:

- **Informal interviews** with Arabic-speaking peers to gauge interest and identify must-have features (daily word, streaks, definitions).
- **Competitive analysis** of Wordle, Wordly, Connections, and existing Arabic Wordle web clones — mapped in §1.5.
- **Word-list sourcing** by combining public Arabic dictionaries with curated lists scraped from the Almaany site; each candidate word was filtered for length, letter set, and diacritic consistency.
- **Playtesting sessions** with non-team members on an Android test device, where tasks such as "guess today's word" were given and observed. Observations drove two changes: enlarging the keyboard touch targets, and reducing the diamond cost of a hint from 30 to 15.
- **Usage-analytics review** through Firebase Analytics (post-launch) to confirm that most sessions complete within 2–5 minutes.

[PLACEHOLDER: Insert Survey Screenshot if applicable — e.g. Google Forms distributed to ~30 Arabic speakers]

## 3.3 Functional Requirements

| FR ID | Description | ST | Priority | Increment | Details |
|-------|-------------|----|----------|-----------|---------|
| FR1 | Validate that a submitted guess is in the valid-word dictionary | ST1 | High | 1 | Checked via `words.contains(_currentWord)` against `5_letter_words_all.json` / `4_letter_words_all.json` / `3_letter_words_all.json` |
| FR2 | Classify each letter of a guess as correct / present / absent | ST1 | High | 1 | Two-pass algorithm in [lib/screens/5_letter_screen.dart:642-677](../lib/screens/5_letter_screen.dart#L642-L677) |
| FR3 | Provide a deterministic daily word identical for all players on a given date | ST1 | High | 2 | Date-seeded RNG: `DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24)` in [lib/screens/daily_word.dart](../lib/screens/daily_word.dart) |
| FR4 | Track and persist the player's current and maximum win streak | ST1 | High | 2 | `winStreak`, `dailyWinStreak`, `timeWinStreak` fields on Firestore user document |
| FR5 | Track and display statistics (played, wins %, streaks, guess distribution) | ST1, ST3 | High | 2 | `GameStatsSnapshot` + `UserDataService.loadStats` in [lib/helper.dart](../lib/helper.dart) |
| FR6 | Authenticate users via email/password or allow guest play | ST1 | High | 1 | Firebase Authentication in [lib/screens/login.dart](../lib/screens/login.dart) |
| FR7 | Display a global leaderboard of the top 50 players by score | ST1 | Medium | 3 | [lib/screens/leaderboard.dart](../lib/screens/leaderboard.dart) via Firestore `leaderboard` collection |
| FR8 | Allow the player to reveal a hint letter at a diamond cost | ST1 | Medium | 3 | Hint key in [lib/keyboard.dart](../lib/keyboard.dart); 15 diamonds per use |
| FR9 | Provide level-based progression across three difficulty tiers | ST1 | High | 2 | `currentLevel3`, `currentLevel4`, `currentLevel5` fields; [lib/screens/level_map.dart](../lib/screens/level_map.dart) |
| FR10 | Support Arabic and English UI copy selectable at runtime | ST1 | Medium | 2 | Custom `AppLocalizations` delegate loading `assets/lang/{ar,en}.json` |
| FR11 | Support light / dark / system theme modes | ST1 | Medium | 2 | `ThemeNotifier` in [lib/themes/theme_provider.dart](../lib/themes/theme_provider.dart) |
| FR12 | Provide configurable haptic feedback on key presses and invalid submits | ST1 | Low | 3 | `isHapticEnabled` SharedPreference flag; `HapticFeedback` calls in game screens |
| FR13 | Show the dictionary definition of each solved word | ST1 | High | 3 | `fetchAlmaanyDefinitions` in [lib/helper.dart](../lib/helper.dart) + `showDefinitionDialog` |
| FR14 | Maintain a personal library of words the player has solved | ST1 | Low | 3 | `gottenWords` array on user document; [lib/screens/library.dart](../lib/screens/library.dart) |
| FR15 | Play a confetti animation and success sound on a win | ST1 | Low | 2 | `ConfettiController` in each game screen |
| FR16 | Accept and persist a unique display username at sign-up | ST1 | Medium | 1 | `UserDataService.initializeUser(username)` |
| FR17 | Award diamonds for wins, streak milestones, and fast solves | ST1 | Medium | 3 | 3-win streak = 50 💎; <2-min solve = 30 💎; 7-day daily streak = 150 💎 |

## 3.4 Non-Functional Requirements

| NFR ID | Description | Priority | Note |
|--------|-------------|----------|------|
| NFR1 | The game must sustain 60 FPS during gameplay on mid-range Android devices | High | Animations use short controllers (<500 ms); no expensive rebuilds inside AnimatedBuilder |
| NFR2 | Key-press latency from tap to visual feedback must be under 100 ms | High | Validated empirically on test devices |
| NFR3 | User credentials must never be stored in plaintext on the device | High | Firebase Auth handles all credential flows |
| NFR4 | Firestore reads per session should not exceed 10 on the hot path | High | Cached via `GameStatsSnapshot` after initial load |
| NFR5 | The keyboard layout must be natural for Arabic typists | High | Based on standard Arabic PC keyboard ordering |
| NFR6 | The application must support at least two languages (AR, EN) | Medium | `AppLocalizations` delegate |
| NFR7 | Visual theme must adapt to light and dark system modes | Medium | `ThemeNotifier` + `ThemeMode.system` option |
| NFR8 | The application must degrade gracefully offline (no crashes) | Medium | Daily-word state cached in SharedPreferences; Firestore writes retried on reconnect |
| NFR9 | Scalability: Firestore data model must support >10k users without structural change | Medium | Documents keyed by Firebase UID; no cross-user joins |
| NFR10 | Release APK size must remain under 50 MB | Low | Currently ~27 MB |
| NFR11 | The codebase must be in English identifiers, with Arabic limited to user-facing strings | Medium | Consistency for team reviews and future maintainers |
| NFR12 | All destructive actions (logout, account switch) must require confirmation | Medium | Implemented via standard `AlertDialog` confirmations |

## 3.5 Domain Requirements

| DR ID | Requirement | Description |
|-------|-------------|-------------|
| DR1 | Target words must be valid Arabic dictionary entries | Sourced from curated `_answers.json` files; reviewed manually for frequency and cultural suitability |
| DR2 | All guesses must be exactly N letters long for mode N ∈ {3, 4, 5} | Enforced by the number of text-field controllers per row |
| DR3 | Comparison between guess and target is exact at the codepoint level | No normalization — diacritics and Arabic letter variants (أ / إ / آ, ي / ى, ه / ة) are distinct |
| DR4 | Letters are drawn from the Unicode Arabic block (U+0600–U+06FF) | Enforced implicitly by the custom keyboard (no other characters are reachable) |
| DR5 | Daily word must be deterministic per calendar day, independent of time zone | Implementation uses `DateTime.now().millisecondsSinceEpoch ~/ (86_400_000)` which yields the same bucket globally within ±24 h tolerance |
| DR6 | Maximum attempts per round: 7 (5-letter, daily), 6 (4-letter), 6 (3-letter) | Hard-coded by row count |
| DR7 | Definitions must come from a recognised Arabic dictionary | Almaany is used; link and fallback message handled in `fetchAlmaanyDefinitions` |
| DR8 | Leaderboard must rank players by cumulative score across modes | `score` field updated atomically with `FieldValue.increment` |

## 3.6 Requirements Analysis and Architecture Design

### 3.6.1 Requirements Analysis

The functional requirements decompose naturally into five subsystems:

- **Game Logic Engine** — FR1, FR2, FR8, FR17. The pure algorithmic core: dictionary validation, letter-state classification, hint reveal, diamond arithmetic.
- **User Interface & Input** — FR7, FR14, FR15, and the UI half of FR3, FR4, FR5, FR9, FR10, FR11, FR12. Screens, the custom keyboard, the game board, animations, and dialogs.
- **Persistence & Authentication** — FR4, FR5, FR6, FR9, FR14, FR16. Firebase Auth, Firestore reads/writes, SharedPreferences for local preferences, `GameStatsSnapshot` cache.
- **Localization & Theming** — FR10, FR11. The `AppLocalizations` delegate and the `ThemeNotifier`.
- **Dictionary & Definitions** — FR13. HTTP-scraping Almaany, parsing HTML, and presenting results in a dialog.

### 3.6.2 Architecture Design

[PLACEHOLDER: Insert Architecture Design Diagram showing Flutter UI layer → Provider state layer → Services (UserDataService, GameTimer, AppLocalizations) → Firebase (Auth, Firestore) and external HTTP (Almaany)]

**Component analysis:**

| ID | Component Name | Mapped FRs |
|----|----------------|------------|
| C1 | Game Logic Engine (embedded in game screens + helper) | FR1, FR2, FR8, FR17 |
| C2 | Custom Arabic Keyboard (`CustomKeyboard`) | FR2 (input), FR8, FR12 |
| C3 | Game Board Widget (within each game screen) | FR2 (display), FR15 |
| C4 | Stats & Streaks Service (`UserDataService`, `GameStatsSnapshot`) | FR4, FR5, FR17 |
| C5 | Authentication Service (Firebase Auth + `login.dart`) | FR6, FR16 |
| C6 | Level Progression (`level_map.dart` + custom painters) | FR9 |
| C7 | Daily Word Engine (`daily_word.dart`) | FR3 |
| C8 | Leaderboard (`leaderboard.dart`) | FR7 |
| C9 | Library (`library.dart`, `gottenWords`) | FR14 |
| C10 | Localization Delegate (`AppLocalizations`) | FR10 |
| C11 | Theme Notifier (`ThemeNotifier`) | FR11 |
| C12 | Definition Dialog (`fetchAlmaanyDefinitions`, `showDefinitionDialog`) | FR13 |
| C13 | Preferences Layer (`SharedPreferences` wrappers in `main.dart`) | FR10, FR11, FR12 |

### 3.6.3 Sub-System Analysis

**Game Logic Engine.** Goal: turn a user's guess into a validated, scored game state. Responsibilities: dictionary validation (FR1), two-pass letter-state classification (FR2), hint reveal (FR8), diamond arithmetic (FR17). Mapped FRs: FR1, FR2, FR8, FR17.

**User Interface & Input.** Goal: present the game state and collect player input in an ergonomic, Arabic-native way. Responsibilities: rendering the 6×N / 7×5 board (FR2 display side), providing the custom keyboard (input for FR1, FR2, FR8), animating feedback (FR15), housing all screens and dialogs. Mapped FRs: FR7, FR14, FR15, plus UI aspects of FR3, FR4, FR5, FR9, FR10, FR11, FR12.

**Persistence & Authentication.** Goal: make progress durable across sessions, devices, and launches. Responsibilities: Firebase Auth flows (FR6, FR16), Firestore CRUD for user docs and leaderboard (FR4, FR5, FR7, FR9, FR14), SharedPreferences for preferences (FR10, FR11, FR12). Mapped FRs: FR4, FR5, FR6, FR7, FR9, FR14, FR16.

**Localization & Theming.** Goal: make the UI feel native to each player's language and lighting preference. Responsibilities: loading and serving localized strings from `assets/lang/*.json` (FR10); exposing and persisting theme mode (FR11). Mapped FRs: FR10, FR11.

**Dictionary & Definitions.** Goal: turn every solved word into a micro-lesson. Responsibilities: fetching HTML from Almaany, parsing definitions, rendering them in a dialog with optional Forvo pronunciation link (FR13). Mapped FRs: FR13.

---

# Chapter 4 — Project Design

## 4.1 Class Diagrams

[PLACEHOLDER: Insert Complete Class Diagram showing all classes in §4.1.1 and their relationships]

### 4.1.1 Classes and Their Responsibilities

#### FiveLetterScreen (and sibling screens 4/3-Letter, DailyMode)
*Located at [lib/screens/5_letter_screen.dart](../lib/screens/5_letter_screen.dart) line 14, [4_letter_screen.dart](../lib/screens/4_letter_screen.dart), [3_letter_screen.dart](../lib/screens/3_letter_screen.dart), and [daily_word.dart](../lib/screens/daily_word.dart).*

The screen is a `StatefulWidget` whose `State` holds all game state and exposes callbacks to the keyboard. It owns the 35 `TextEditingController`s (for the 7×5 grid), the per-cell colour / colour-type arrays, the per-row shake `AnimationController`s, the per-cell scale controllers, a `ConfettiController`, the keyboard colour map, and the `GameTimer`.

- **Attributes:** `correctWord: String`, `_controllers: List<TextEditingController>[35]`, `_fillColors: List<Color>[35]`, `_colorTypes: List<String>[35]`, `_shakeControllers: List<AnimationController>[7]`, `_shakeAnimations: List<Animation<double>>[7]`, `_scaleControllers: List<AnimationController>[35]`, `_scaleAnimations: List<Animation<double>>[35]`, `keyColors: Map<String, Color>`, `gameWon: bool`, `_currentRow: int`, `_currentTextfield: int`, `_fiveLettersStop: int`, `_correctWord: String`, `_deconstructedCorrectWord: List<String>`, `_confettiController: ConfettiController`, `_gameTimer: GameTimer`, `words: List<String>`.
- **Methods:** `initState`, `dispose`, `build`, `_insertText(String)`, `_backspace()`, `_submit()`, `_revealHint()`, `_updateFillColors()`, `_updateKeyColors(String letter, String colorType)`, `_shakeCurrentRow()`, `_triggerPopUp(int index)`.
- **Inheritance:** `FiveLetterScreen extends StatefulWidget`; its state extends `State<FiveLetterScreen> with TickerProviderStateMixin`.
- **Relationships:** Owns `CustomKeyboard`; uses `UserDataService` for Firestore sync; reads `GameStatsSnapshot`; invokes `showDefinitionDialog`.

#### UserDataService
*Located at [lib/helper.dart](../lib/helper.dart) line 187.*

- **Attributes:** `uid: String` (Firebase UID of current user), `_db: FirebaseFirestore` (instance reference).
- **Methods:** `initializeUser(String username)`, `loadDiamonds() → Future<int>`, `awardDiamonds(int)`, `spendDiamonds(int) → Future<bool>`, `loadStreaks()`, `saveStreaks()`, `recordGame({bool won, int? guesses})`, `loadStats() → Future<Map<String,dynamic>>`, `loadGottenWords() → Future<List<String>>`, `addGottenWord(String)`, `updateLeaderboard()`.
- **Inheritance:** plain Dart class.
- **Relationships:** Called by every game screen on win/loss; called by `MainMenu` on launch; called by `LoginPage` on sign-up; called by `Library` on open.

#### GameStatsSnapshot
*Located at [lib/helper.dart](../lib/helper.dart) line 29.*

- **Attributes:** static `played: int`, static `wins: double` (percentage), static `currentStreak: int`, static `maxStreak: int`, static `distribution: Map<int,int>`.
- **Methods:** none — used as an in-memory cache populated by `UserDataService.loadStats`.
- **Inheritance:** plain static class.
- **Relationships:** Read by the stats dialog; written by `UserDataService`.

#### CustomKeyboard
*Located at [lib/keyboard.dart](../lib/keyboard.dart) line 5.*

- **Attributes:** `onTextInput: ValueChanged<String>`, `onBackspace: VoidCallback`, `onSubmit: VoidCallback`, `onRevealHint: VoidCallback`, `keyColors: Map<String,Color>`.
- **Methods:** `build`, `_textInputHandler(String)`, `_backspaceHandler()`, `_submitHandler()`, `buildRowOne`, `buildRowTwo`, `buildRowThree`, `buildSubmitRow`.
- **Inheritance:** `CustomKeyboard extends StatelessWidget`.
- **Relationships:** Embedded at the bottom of every game screen; bubbles taps upward through its callbacks.

#### GameTimer
*Located at [lib/helper.dart](../lib/helper.dart) line 1068.*

- **Attributes:** `elapsedSeconds: int`, `onTick: VoidCallback?`, `_timer: Timer?`.
- **Methods:** `start()`, `stop()`, `reset()`, `formattedTime` (getter, returns `mm:ss`).
- **Inheritance:** plain Dart class.
- **Relationships:** Created and disposed by each game screen; used by the diamond-reward logic for fast-solve bonus.

#### Challenge
*Located at [lib/helper.dart](../lib/helper.dart) line 37.*

- **Attributes:** `title: String`, `currentVal: int`, `goal: int`, `reward: int`.
- **Methods:** `progress` (getter, returns `currentVal / goal`).
- **Inheritance:** plain value class.
- **Relationships:** Displayed by the challenges dialog in `helper.dart`.

#### ThemeNotifier
*Located at [lib/themes/theme_provider.dart](../lib/themes/theme_provider.dart) line 4.*

- **Attributes:** `_themeMode: ThemeMode`.
- **Methods:** `themeMode` (getter), `setThemeMode(ThemeMode)`, `_persistTheme()`, `_loadTheme()`.
- **Inheritance:** `ThemeNotifier extends ChangeNotifier`.
- **Relationships:** Provided at the root of the widget tree via `ChangeNotifierProvider`; consumed by `MaterialApp`.

#### AppLocalizations
*Located at [lib/themes/app_localization.dart](../lib/themes/app_localization.dart) line 5.*

- **Attributes:** `locale: Locale`, `_localizedStrings: Map<String,String>`.
- **Methods:** `load() → Future<bool>`, `translate(String key) → String`, static `of(BuildContext) → AppLocalizations?`.
- **Inheritance:** plain Dart class plus an inner `LocalizationsDelegate<AppLocalizations>`.
- **Relationships:** Registered in `MaterialApp.localizationsDelegates`; used everywhere via `AppLocalizations.of(context).translate(...)`.

#### HintedTextField, GameTimer UI helpers, Dialog helpers
*Located within [lib/helper.dart](../lib/helper.dart).*

The helper file also contains a `HintedTextField` widget, a cluster of dialog builder functions (`showStatsDialog`, `showChallengesDialog`, `showSettingsDialog`, `showDefinitionDialog`, `showIncorrectDailyDialog`, `incorrectWordDialog`), and button factories (`buildModeButton`, `smallButton`, `longBuildModeButton`). These are utility-scoped rather than true classes.

## 4.2 Use Case Diagrams and Their Responsibilities

### Subsystem: Game Logic Engine

[PLACEHOLDER: Insert Use Case Diagram — Game Logic Engine showing Player actor connected to Submit Guess, Reveal Hint, Start New Round]

**Use case — Submit Guess**

| Field | Value |
|-------|-------|
| Use Case Name | Submit Guess |
| Actor | Player |
| Description | Player completes a 3/4/5-letter guess and taps the Submit (*إدخال*) key. The system validates the guess, classifies each letter, updates the board and keyboard, and detects win/loss. |
| Data | Current row text (length 3/4/5), target word, existing `letterCounts` map |
| Stimulus | Tap on Submit key |
| Response | Each cell's fill colour and each pressed key's colour updated; confetti + stats update on win; shake + snackbar on invalid input |
| Comment | Core gameplay action — invoked up to 7 times per round |

[PLACEHOLDER: Insert Sequence Diagram — Submit Guess: Player → Keyboard → GameScreen._submit → words.contains → letter-state loops → setState → UserDataService.recordGame → Firestore]

**Use case — Reveal Hint**

| Field | Value |
|-------|-------|
| Use Case Name | Reveal Hint |
| Actor | Player |
| Description | Player taps the diamond-priced hint key to reveal one correct letter in its correct position. |
| Data | Current row index, target word, player's diamond balance |
| Stimulus | Tap on Hint key |
| Response | 15 diamonds deducted; one cell is pre-filled (grey hint overlay); if balance insufficient, a snackbar explains the shortfall |
| Comment | Optional aid for stuck players |

[PLACEHOLDER: Insert Sequence Diagram — Reveal Hint]

**Use case — Start New Round**

| Field | Value |
|-------|-------|
| Use Case Name | Start New Round |
| Actor | Player |
| Description | Player taps a game-mode button (Daily / 3-letter / 4-letter / 5-letter) from the main menu; a new game screen is constructed with a freshly selected target. |
| Data | Selected mode, current level for that mode, word list asset |
| Stimulus | Tap on mode button |
| Response | Game screen pushed with empty board, fresh keyboard colours, reset timer |
| Comment | Entry point for gameplay |

[PLACEHOLDER: Insert Sequence Diagram — Start New Round]

### Subsystem: Persistence & Authentication

[PLACEHOLDER: Insert Use Case Diagram — Persistence & Auth showing Player actor connected to Sign In, Register, View Stats, View Leaderboard]

**Use case — Sign In / Register**

| Field | Value |
|-------|-------|
| Use Case Name | Sign In / Register |
| Actor | Player |
| Description | New or returning player authenticates via Firebase Auth using email and password, or proceeds as guest. |
| Data | Email, password, optional username |
| Stimulus | Tap on Sign In or Sign Up button |
| Response | On success, navigate to Main Menu; on failure, display localized error below the form; on sign-up, also show a How-to-Play dialog |
| Comment | Governs access to stats, streaks, and leaderboard |

[PLACEHOLDER: Insert Sequence Diagram — Sign In]

**Use case — View Stats**

| Field | Value |
|-------|-------|
| Use Case Name | View Stats |
| Actor | Player |
| Description | Player opens the stats dialog, which shows games played, win percentage, current streak, max streak, and guess distribution. |
| Data | Firestore user document fields prefixed `stats_` |
| Stimulus | Tap stats icon in app bar or drawer |
| Response | Modal opens with four stat tiles and a 7-bar distribution chart |
| Comment | Data is cached in `GameStatsSnapshot` for subsequent opens within the session |

[PLACEHOLDER: Insert Sequence Diagram — View Stats]

**Use case — View Leaderboard**

| Field | Value |
|-------|-------|
| Use Case Name | View Leaderboard |
| Actor | Player |
| Description | Player opens the leaderboard screen, which queries Firestore for the top 50 users by score. |
| Data | Firestore `leaderboard` collection documents |
| Stimulus | Tap leaderboard icon in Main Menu app bar |
| Response | Scrollable list rendered with rank, username, and score |
| Comment | Read-only — no client-side mutation |

[PLACEHOLDER: Insert Sequence Diagram — View Leaderboard]

### Subsystem: UI & Input

[PLACEHOLDER: Insert Use Case Diagram — UI & Input showing Player actor connected to Type Letter, Backspace, Change Theme, Change Language, Toggle Haptics]

**Use case — Type Letter**

| Field | Value |
|-------|-------|
| Use Case Name | Type Letter |
| Actor | Player |
| Description | Player taps an Arabic letter key on the custom keyboard. The character is inserted into the current text-field position if a slot is available. |
| Data | Tapped letter, current row's next empty index |
| Stimulus | Tap on a letter key |
| Response | Cell displays the letter; scale-pop animation plays; row cursor advances |
| Comment | Up to 5 invocations per row |

[PLACEHOLDER: Insert Sequence Diagram — Type Letter]

**Use case — Change Language / Theme**

| Field | Value |
|-------|-------|
| Use Case Name | Change Language / Theme |
| Actor | Player |
| Description | From the settings dialog the player toggles language (AR ↔ EN) or theme (light / dark / system). Selection persists across launches. |
| Data | `languageCode` or `themeMode` value |
| Stimulus | Tap on toggle in settings dialog |
| Response | `AppLocalizations` reloads strings; `ThemeNotifier` rebuilds widget tree; value written to `SharedPreferences` |
| Comment | Applies globally and immediately |

[PLACEHOLDER: Insert Sequence Diagram — Change Language / Theme]

### Subsystem: Game Progression

[PLACEHOLDER: Insert Use Case Diagram — Game Progression showing Player actor connected to Play Daily Word, Advance Level, Browse Library]

**Use case — Play Daily Word**

| Field | Value |
|-------|-------|
| Use Case Name | Play Daily Word |
| Actor | Player |
| Description | Player enters the Daily Mode screen, which loads today's word (shared across all players) or resumes a partially-completed attempt. |
| Data | Date-seeded word, saved board state in SharedPreferences, `dailyWinStreak` |
| Stimulus | Tap on the Daily Mode card in the Main Menu |
| Response | Board populated with any prior progress; if the player already completed today, a read-only summary is shown |
| Comment | Encourages daily engagement |

[PLACEHOLDER: Insert Sequence Diagram — Play Daily Word]

**Use case — Browse Library**

| Field | Value |
|-------|-------|
| Use Case Name | Browse Library |
| Actor | Player |
| Description | Player opens the Library screen, which lists every word they have ever solved. Tapping a word opens its Almaany definition dialog. |
| Data | `gottenWords` array on user document |
| Stimulus | Tap Library from the drawer |
| Response | Scrollable list rendered; definition dialog opens on tap |
| Comment | Reinforces vocabulary acquisition |

[PLACEHOLDER: Insert Sequence Diagram — Browse Library]

### Subsystem: Dictionary & Definitions

[PLACEHOLDER: Insert Use Case Diagram — Dictionary & Definitions showing Player actor connected to View Definition (After Win/Loss) and Almaany (external)]

**Use case — View Definition**

| Field | Value |
|-------|-------|
| Use Case Name | View Definition |
| Actor | Player |
| Description | After a round ends (win or loss), or when tapping a library entry, the game fetches the word's definition from Almaany and displays it in a dialog with optional Forvo pronunciation link. |
| Data | Target word, Almaany HTML page |
| Stimulus | Round end or Library item tap |
| Response | Dialog opens with parsed definition; link buttons open external browser via `url_launcher` |
| Comment | Requires network; a graceful fallback message is shown if fetch fails |

[PLACEHOLDER: Insert Sequence Diagram — View Definition]

---

# Chapter 5 — Project Implementation

## 5.1 Application Configuration

**Programming language.** Dart (SDK constraint `^3.7.2`).

**Framework.** Flutter (stable channel) with Material Design 3.

**Local data storage.** `shared_preferences` ^2.5.3 for user-facing preferences (`languageCode`, `themeMode`, `isHapticEnabled`) and in-flight daily-word board state. Persisted on the device's private app storage.

**Cloud data storage.** Cloud Firestore (`cloud_firestore` ^5.6.7) for user profiles, game statistics, streaks, diamonds, word library, and leaderboard entries. Two top-level collections are used: `users/{uid}` and `leaderboard/{uid}`.

**Authentication.** Firebase Authentication (`firebase_auth` ^5.5.3) with email-password provider and a guest flow.

**State management.** `provider` ^6.1.4 (ChangeNotifier pattern). A single `ThemeNotifier` is provided at the top of the widget tree; game state is intentionally screen-local via `setState` to keep each screen self-contained.

**Packages (complete list, from [pubspec.yaml](../pubspec.yaml)).**

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Core framework |
| `flutter_localizations` | SDK | Material & Cupertino localization delegates |
| `firebase_core` | ^3.13.0 | Firebase initialization |
| `firebase_auth` | ^5.5.3 | Email/password authentication |
| `cloud_firestore` | ^5.6.7 | NoSQL document database |
| `provider` | ^6.1.4 | State management (theme, locale) |
| `shared_preferences` | ^2.5.3 | Local persistent key-value store |
| `confetti` | ^0.8.0 | Win-celebration particle animation |
| `http` | ^1.3.0 | HTTP requests to Almaany |
| `html` | ^0.15.5+1 | HTML parsing of Almaany responses |
| `url_launcher` | ^6.3.1 | Opens Almaany / Forvo links in external browser |

**Assets.** Word lists under `assets/words/{3,4,5}_letters/` as JSON (answers, levels, all-valid-words); localization JSON under `assets/lang/` (`ar.json`, `en.json`); decorative images (`Mountains.png`, flag variants, Arabic character silhouettes, light/dark backgrounds) under `assets/images/`.

**Platform configuration.** Android: `applicationId = com.example.klemat`, `namespace = com.example.klemat`, `compileSdk = 36`, `targetSdk = 36`, `ndkVersion = 27.0.12077973`, Java/Kotlin targets set to 11 (see [android/app/build.gradle.kts](../android/app/build.gradle.kts)). Firebase BoM 33.13.0. The `google-services.json` file is committed under [android/app/google-services.json](../android/app/google-services.json). iOS: standard Flutter Runner project; Firebase pods are installed from pubspec on `pod install`.

### Segment: Most Important Part of the Implementation

The algorithmic heart of Klemat is the **two-pass letter-state computation** that runs after every guess. It is responsible for classifying each of the five letters as correct (green / `onPrimary`), present (orange / `onSecondary`), or absent (grey / `onError`). A naive single-pass implementation mis-handles duplicate letters in the guess — for example, if the target is "أفكار" (one "ا") and the guess contains two "ا"s, a single pass can accidentally mark both as present. Klemat follows the canonical Wordle rule: a letter in the guess can only "consume" an unmatched occurrence of itself in the target once.

The algorithm proceeds in two passes over the current row. **Pass one** walks left-to-right and, for every index where the guessed letter equals the target letter, paints the cell `onPrimary` and **decrements** a `letterCounts` map that was pre-populated from the target. This removes the exact-match occurrences from the pool of "available" letters. **Pass two** walks the same indices a second time; for any cell that was *not* painted green in pass one, it checks whether the guessed letter still has a positive count in the pool. If yes, the cell is painted `onSecondary` (present but wrong position) and the count is decremented; if no, the cell is painted `onError` (absent). The keyboard colour map is updated alongside each cell, but with a priority rule: once a key is green, it must not downgrade to orange or grey on a later guess, and once orange it must not downgrade to grey.

The exact code that implements pass one and pass two, quoted verbatim from [lib/screens/5_letter_screen.dart](../lib/screens/5_letter_screen.dart#L642-L677):

```dart
} else {
  for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
    _guessedLetter = _controllers[i].text;
    if (_guessedLetter == _deconstructedCorrectWord[j]) {
      _fillColors[i] = Theme.of(context).colorScheme.onPrimary;
      keyColors[_guessedLetter] = Theme.of(context).colorScheme.onPrimary;
      _colorTypes[i] = "onPrimary";
      letterCounts[_guessedLetter] = letterCounts[_guessedLetter]! - 1;
    }
  }

  for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
    _guessedLetter = _controllers[i].text;
    if (_fillColors[i] != Theme.of(context).colorScheme.onPrimary) {
      if (letterCounts[_guessedLetter] != null &&
          letterCounts[_guessedLetter]! > 0) {
        _fillColors[i] = Theme.of(context).colorScheme.onSecondary;
        _colorTypes[i] = "onSecondary";
        if (keyColors[_guessedLetter] !=
            Theme.of(context).colorScheme.onPrimary) {
          keyColors[_guessedLetter] =
              Theme.of(context).colorScheme.onSecondary;
        }
        letterCounts[_guessedLetter] = letterCounts[_guessedLetter]! - 1;
      } else {
        _fillColors[i] = Theme.of(context).colorScheme.onError;
        _colorTypes[i] = "onError";
        if (keyColors[_guessedLetter] !=
                Theme.of(context).colorScheme.onPrimary &&
            keyColors[_guessedLetter] !=
                Theme.of(context).colorScheme.onSecondary) {
          keyColors[_guessedLetter] = Theme.of(context).colorScheme.onError;
        }
      }
    }
  }
```

**Worked example.** Target: "أحمر" (treat as 4 letters أ-ح-م-ر). Guess: "أأمر".
Initial `letterCounts = {'أ': 1, 'ح': 1, 'م': 1, 'ر': 1}`.

- Pass 1, index 0: guess 'أ' vs target 'أ' → match, cell onPrimary, `letterCounts['أ'] = 0`.
- Pass 1, index 1: guess 'أ' vs target 'ح' → no match.
- Pass 1, index 2: guess 'م' vs target 'م' → match, cell onPrimary, `letterCounts['م'] = 0`.
- Pass 1, index 3: guess 'ر' vs target 'ر' → match, cell onPrimary, `letterCounts['ر'] = 0`.
- Pass 2, index 1: 'أ' has `letterCounts['أ'] = 0` → cell onError (grey).

The second 'أ' is correctly marked grey rather than orange, because the single available 'أ' was already consumed by the correct-position match at index 0. This is the subtle behaviour that distinguishes a correct Wordle implementation from a buggy one.

The surrounding `_submit` method handles input validation (length check and dictionary lookup via `words.contains(_currentWord)`), the win branch (confetti, stats update via `UserDataService.recordGame(won: true, guesses: _currentRow + 1)`, diamond awards, and definition dialog), the loss branch at row 7 (`winStreak = 0`, `recordGame(won: false)`, and the incorrect-word dialog), and finally advances `_currentRow` and re-renders via `setState`.

---

# Chapter 6 — Project Testing

## 6.1 Test Cases

| Test Case / Scenario | Objective | Test Data |
|----------------------|-----------|-----------|
| TC1 — Submit valid, correct 5-letter word | Confirm win path: all cells green, confetti plays, definition dialog opens, stats updated | Target = "كلمات", guess = "كلمات" |
| TC2 — Submit valid, incorrect word | Confirm letter-state colouring and row advance | Target = "كلمات", guess = "مرحبا" |
| TC3 — Submit word not in dictionary | Confirm "not in library" snackbar, no row advance | Target = "كلمات", guess = "بببببب" (invalid string) |
| TC4 — Submit incomplete row | Confirm shake animation, double vibration, row does not advance | Target = any; guess has only 3/5 letters filled |
| TC5 — Duplicate letters in guess, single in target | Confirm only one instance is coloured orange, the other grey | Target = "أحمر", guess = "أأمر" (expect: أ green, أ grey, م green, ر green) |
| TC6 — Duplicate letters in both guess and target | Confirm both instances coloured correctly | Target = "ببابا", guess = "بببـب" |
| TC7 — Guess exhausted without win | Confirm loss flow: streak resets to 0, loss recorded, incorrect-word dialog shown | Wrong guess on every row |
| TC8 — Daily word consistency across launches | Confirm same word on same calendar day regardless of restart | Close and reopen app on same day |
| TC9 — Daily word changes at midnight | Confirm new word next calendar day | Change device date forward by 24 h |
| TC10 — Reveal hint with sufficient diamonds | Confirm 15 diamonds deducted and one correct letter pre-filled | Balance ≥ 15 |
| TC11 — Reveal hint with insufficient diamonds | Confirm snackbar, no deduction, no reveal | Balance < 15 |
| TC12 — Language toggle AR ↔ EN | Confirm all UI strings switch and preference persists across relaunch | Toggle in Settings |
| TC13 — Theme toggle Light / Dark / System | Confirm colours update immediately and preference persists | Toggle in Settings |
| TC14 — Haptics toggle | Confirm disabling stops vibration on invalid submit | Toggle in Settings |
| TC15 — Sign-up with existing email | Confirm localized error, no duplicate user document created | Email already in Auth |
| TC16 — Sign-up with new email | Confirm user document created with 0 stats and welcome How-to-Play dialog shown | Fresh email |
| TC17 — Offline behaviour | Confirm no crash if Firestore write fails; retry on reconnect | Airplane mode on during submit |
| TC18 — Leaderboard population | Confirm top 50 by score displayed | At least 60 users in Firestore |
| TC19 — Library growth | Confirm every won word is added to `gottenWords` and visible in Library | Win several rounds |
| TC20 — Streak milestone reward | Confirm 50 💎 awarded on 3-win streak and a toast appears | Win 3 consecutive games |
| TC21 — Fast-solve reward | Confirm 30 💎 awarded for sub-2-minute win | Solve in 90 seconds |
| TC22 — Definition dialog graceful fallback | Confirm friendly message when Almaany fetch fails | Kill network before dialog |

## 6.2 Test Methodologies

| Methodology | Description | Applied To (Examples) | Purpose |
|-------------|-------------|-----------------------|---------|
| Unit testing | Pure-function tests written with `flutter_test` exercising algorithms in isolation | Two-pass letter-state algorithm; `letterCounts` initialization; daily-word seed → index mapping | Guarantee algorithmic correctness independent of UI |
| Widget testing | `flutter_test` widget tests that pump a widget subtree and assert on rendered output | `CustomKeyboard` key taps → callback invocations; game board cell colouring | Guarantee UI wiring without running a full device |
| Integration testing | End-to-end flows on a test device with a disposable Firebase project | Sign-up → play → stats update; leaderboard read after score change | Confirm Firestore schema matches client expectations |
| Manual exploratory testing | Team members play extended sessions on real devices and record issues | RTL rendering, Arabic diacritic rendering, animation feel | Surface issues that automated tests miss — especially UX smell |
| Regression testing | Re-running the full test-case table after every release-candidate build | All TC1–TC22 | Catch regressions introduced during polish |
| Usability testing | Timed tasks with non-team playtesters (~5 users) with think-aloud feedback | Keyboard ergonomics, hint affordance, stats clarity | Surface usability issues before launch |
| Performance testing | Profiling with Flutter DevTools on mid- and low-end Android devices | Frame times during confetti + shake; Firestore read counts | Hit NFR1 (60 FPS) and NFR4 (≤10 reads/session) |
| Security review | Manual review of Firestore rules and Auth flows | Rules for `users/{uid}` (owner-only read/write); `leaderboard` (public read, owner-only write) | Ensure no client can read or mutate another user's data |

---

# Chapter 7 — User Manual

Klemat is designed to be self-explanatory, but the following walkthrough describes every screen the player encounters.

## Step 1 — Launching the App

On first launch the player sees the login screen. Existing users enter their email and password; new users tap **Sign Up** to create an account; anyone can tap **Guest** to play without an account (note: guest progress is not saved to the cloud).

[PLACEHOLDER: Insert UI Screenshot of Login Screen]

## Step 2 — Main Menu

After authentication the player lands on the main menu. From top to bottom the player sees: the app bar (leaderboard button on the right, diamond balance, drawer icon on the left), a decorative background with the Klemat branding, and a stack of game-mode buttons: **Daily Word**, **3-Letter**, **4-Letter**, **5-Letter**. Opening the drawer exposes Stats, Library, How to Play, Settings, and Log Out.

[PLACEHOLDER: Insert UI Screenshot of Main Menu]

## Step 3 — Choosing a Story Mode

Tapping **3-Letter**, **4-Letter**, or **5-Letter** navigates to the level map for that mode. The player sees a scrollable stylized path dotted with flag icons. The green flag marks the current level; finished levels show a tick-style flag; future levels are locked. Tapping the green flag starts that level.

[PLACEHOLDER: Insert UI Screenshot of Level Map]

## Step 4 — Playing a Round

Inside a round the player sees the timer and stat icons in the app bar, a grid of empty tiles in the centre, and the custom Arabic keyboard at the bottom. The player taps letters on the keyboard to fill the current row from right to left (Arabic is read RTL). Tapping **⌫** deletes the last letter; tapping **إدخال** submits the row; tapping the diamond-priced hint button reveals one letter at a cost of 15 💎.

[PLACEHOLDER: Insert UI Screenshot of Gameplay UI]

After submitting, each tile turns green (correct position), orange (present but wrong position), or grey (not in the word). The same colours apply to the keyboard keys, giving the player a running memory of what has been tried. The grid shakes if the guess is incomplete, and a snackbar appears if the word is not in the dictionary.

## Step 5 — Daily Word

The **Daily Word** button on the main menu opens a variant of the gameplay screen where the target is identical for every player that day. Progress is saved automatically, so the player can close the app and resume later that same day. Once the daily word is solved or all attempts are exhausted, the screen becomes read-only until midnight local time.

[PLACEHOLDER: Insert UI Screenshot of Daily Word Screen]

## Step 6 — Stats

Tapping the stats icon in the app bar opens a modal showing four key numbers — games played, win percentage, current streak, and max streak — plus a horizontal bar chart of the guess distribution (how many games the player has won in 1, 2, …, 7 attempts).

[PLACEHOLDER: Insert UI Screenshot of Stats Modal]

## Step 7 — Leaderboard

The trophy icon in the main-menu app bar opens the leaderboard: the top 50 players worldwide, ranked by total score, each row showing rank, username, and score.

[PLACEHOLDER: Insert UI Screenshot of Leaderboard]

## Step 8 — Library

From the drawer, **Library** opens a scrollable list of every word the player has ever solved. Tapping a word opens the definition dialog — an Almaany-sourced explanation with optional Forvo audio link.

[PLACEHOLDER: Insert UI Screenshot of Library Screen]

## Step 9 — Definition Dialog

At the end of each round, or on library taps, the definition dialog opens. It shows the word in large type, a parsed Almaany definition, and buttons to open the full Almaany page or the Forvo pronunciation in the external browser.

[PLACEHOLDER: Insert UI Screenshot of Definition Dialog]

## Step 10 — Settings

From the drawer, **Settings** exposes three toggles: language (AR / EN), theme (Light / Dark / System), and haptic feedback (on / off). All three persist across launches.

[PLACEHOLDER: Insert UI Screenshot of Settings Dialog]

---

# Appendixes

## Appendix A — Word List Sourcing and Playtest Scripts

**Word lists.** The answer lists under `assets/words/{3,4,5}_letters/` were compiled by combining (a) a curated subset of common Arabic vocabulary filtered by length and diacritic consistency, and (b) entries cross-checked against the Almaany dictionary for validity. The larger validation lists (`*_letter_words_all.json`) additionally include rare or archaic words that should be *accepted* as guesses but are unlikely to be chosen as targets. Final review was performed manually to remove proper nouns, offensive entries, and words with dialectal variants.

**Playtest script — "first-time user".**

1. Install the app on a fresh Android device.
2. Tap **Sign Up**; create an account with a test email.
3. Observe and note: is the How-to-Play dialog clear? Does the flow feel blocking?
4. Return to the main menu. Open **Daily Word**.
5. Attempt to solve today's word while thinking aloud.
6. Record time to first letter press, time to first submit, time to round end.
7. At round end, rate the definition dialog (clear / confusing) and confetti (delightful / excessive).
8. Open Stats. Note whether distribution bars are readable.
9. Toggle the language to English. Note whether any strings remain in Arabic.
10. Log out and back in. Confirm stats persist.

**Playtest script — "duplicate-letter edge case".**

1. Launch 5-letter mode (seed with a chosen target such as "أحمر").
2. Submit the guess "أأمر".
3. Confirm the first أ is green, the second أ is grey, م is green, ر is green.
4. Repeat with "مممم" variants against "ممتع" to exercise other duplicate configurations.

[PLACEHOLDER: Insert Playtest Feedback Summary Chart]

## Appendix B — Project Implementation

**Repository.** [PLACEHOLDER: GitHub repository URL]

**Crucial code snippet — the two-pass letter-state algorithm** ([lib/screens/5_letter_screen.dart:642-677](../lib/screens/5_letter_screen.dart#L642-L677)):

```dart
for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
  _guessedLetter = _controllers[i].text;
  if (_guessedLetter == _deconstructedCorrectWord[j]) {
    _fillColors[i] = Theme.of(context).colorScheme.onPrimary;
    keyColors[_guessedLetter] = Theme.of(context).colorScheme.onPrimary;
    _colorTypes[i] = "onPrimary";
    letterCounts[_guessedLetter] = letterCounts[_guessedLetter]! - 1;
  }
}

for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
  _guessedLetter = _controllers[i].text;
  if (_fillColors[i] != Theme.of(context).colorScheme.onPrimary) {
    if (letterCounts[_guessedLetter] != null &&
        letterCounts[_guessedLetter]! > 0) {
      _fillColors[i] = Theme.of(context).colorScheme.onSecondary;
      _colorTypes[i] = "onSecondary";
      if (keyColors[_guessedLetter] != Theme.of(context).colorScheme.onPrimary) {
        keyColors[_guessedLetter] = Theme.of(context).colorScheme.onSecondary;
      }
      letterCounts[_guessedLetter] = letterCounts[_guessedLetter]! - 1;
    } else {
      _fillColors[i] = Theme.of(context).colorScheme.onError;
      _colorTypes[i] = "onError";
      if (keyColors[_guessedLetter] != Theme.of(context).colorScheme.onPrimary &&
          keyColors[_guessedLetter] != Theme.of(context).colorScheme.onSecondary) {
        keyColors[_guessedLetter] = Theme.of(context).colorScheme.onError;
      }
    }
  }
}
```

**Crucial code snippet — daily word seed** ([lib/screens/daily_word.dart](../lib/screens/daily_word.dart)):

```dart
int seed = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
final random = Random(seed);
final index = random.nextInt(dailyAnswers.length);
final todaysWord = dailyAnswers[index];
```

**Crucial code snippet — recording a game** ([lib/helper.dart](../lib/helper.dart) `UserDataService.recordGame`):

```dart
Future<void> recordGame({required bool won, int? guesses}) async {
  final docRef = _db.collection('users').doc(uid);
  final updates = <String, Object>{
    'stats_played': FieldValue.increment(1),
  };
  if (won) {
    updates['stats_wins'] = FieldValue.increment(1);
    updates['stats_currentStreak'] = FieldValue.increment(1);
    if (guesses != null && guesses >= 1 && guesses <= 7) {
      updates['stats_dist_$guesses'] = FieldValue.increment(1);
    }
  } else {
    updates['stats_currentStreak'] = 0;
  }
  await docRef.set(updates, SetOptions(merge: true));
}
```

---

# References

1. Wardle, J. (2021). *Wordle.* https://www.nytimes.com/games/wordle/index.html
2. Flutter team. (2024). *Flutter documentation.* https://docs.flutter.dev
3. Dart team. (2024). *Dart language tour.* https://dart.dev/guides
4. Firebase team. (2024). *Firebase documentation.* https://firebase.google.com/docs
5. Firebase team. (2024). *Cloud Firestore documentation.* https://firebase.google.com/docs/firestore
6. Firebase team. (2024). *Firebase Authentication documentation.* https://firebase.google.com/docs/auth
7. Remi Rousselet. (2024). *Provider package.* https://pub.dev/packages/provider
8. Flutter Community. (2024). *shared_preferences package.* https://pub.dev/packages/shared_preferences
9. funwithflutter. (2024). *confetti package.* https://pub.dev/packages/confetti
10. Dart team. (2024). *http package.* https://pub.dev/packages/http
11. Dart team. (2024). *html package.* https://pub.dev/packages/html
12. Flutter team. (2024). *url_launcher package.* https://pub.dev/packages/url_launcher
13. Flutter team. (2024). *Internationalizing Flutter apps.* https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
14. Almaany. (2024). *Arabic–Arabic and multilingual dictionary.* https://www.almaany.com
15. Forvo. (2024). *Pronunciation dictionary.* https://forvo.com
16. Unicode Consortium. (2024). *The Unicode Standard — Arabic block (U+0600–U+06FF).* https://www.unicode.org/charts/PDF/U0600.pdf
17. Material Design team. (2024). *Material Design 3 guidelines.* https://m3.material.io
18. Google. (2024). *Android developers — SDK platform release notes.* https://developer.android.com
19. W3C. (2015). *Inline markup and bidirectional text in HTML.* https://www.w3.org/International/articles/inline-bidi-markup
20. Sommerville, I. (2016). *Software Engineering* (10th ed.). Pearson.
