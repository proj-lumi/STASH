# Stash

A fully offline budgeting app for tracking income, expenses, and transfers across multiple accounts, with per-category budgets and spending statistics.

<video src="docs/demo.mp4" autoplay muted loop playsinline>
  Your browser does not support the video tag.
</video>

*Stash app tutorial demo*

---

## Highlights

- **⚡ Track transactions in a few taps.** Log income, expenses, and transfers with categories and notes.
- **🏦 Multi-account support.** Every account keeps its own running balance.
- **📊 Data-driven insights.** Monthly summaries, spending by category, and 6-month trends as charts.
- **🎯 Per-category budgets.** Set monthly limits and watch spending against them in real time.
- **🔒 Privacy by design.** 100% offline. All data lives on-device — no accounts, no ads, no cloud.

---

## Quick start

```bash
flutter pub get   # install dependencies
flutter run      # run the app
```

Prerequisite: [Flutter SDK](https://docs.flutter.dev/get-started/install). Everything runs locally — no servers or configuration needed.

---

## Tech stack

| What | Used for |
|---|---|
| Flutter / Dart | Cross-platform mobile UI |
| Riverpod | State management |
| Isar | On-device local database |
| fl_chart | Spending statistics & charts |
| shared_preferences / intl / flutter_launcher_icons | Settings, formatting, branding |

---

## About the project

Built as a three-person team for **CCS 8 (Human–Computer Interaction)** at Silliman University College of Computer Studies — our first Flutter project. The course focus was practicing a full HCI design process on a real codebase, and the design reflects that:

- **Iterative user testing.** Each testing round produced concrete fixes — clearer form validation, a required transfer-fee field, and a calmer visual tone (visible in the commit history).
- **Accessibility.** Light/dark mode and adjustable font size.
- **One-handed use.** Content stays within a comfortable reading width on larger screens.

🎬 Watch the **[tutorial video on YouTube](https://youtu.be/wMN_7Li9j-I)**, or find it in-app under *Tutorial*.

> ℹ️ `assets/tutorial.mp4` is intentionally **not** in this repo (16MB — it'd slow every clone). Drop it into `assets/` before building, or just watch the video on YouTube.
