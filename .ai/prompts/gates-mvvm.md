# MVVM Architecture Gates (Mobile)

Apply these gates when the project is a mobile app (Android, iOS, Flutter).

**IMPORTANT:** REPLACE the Clean gates with these. The agent must have only ONE set of gates.

## architect.md — Replace Protocol (Quality Gates)

```markdown
## Protocol (Quality Gates)
1. [Gate 1] (Prevents: ViewModel↔View coupling) ViewModels have zero references to Views, Activities, Contexts or UI framework classes. ViewModels expose state, Views observe it.
2. [Gate 2] (Prevents: data access scattered across layers) Repository pattern enforced: all data access (API, DB, cache) goes through Repositories. ViewModels never call APIs or databases directly.
3. [Gate 3] (Prevents: navigation logic in wrong layer) Navigation handled by the navigation component (NavController, Router, Navigator), not hardcoded in ViewModels or Views.

## Fatal Restrictions
- NEVER reference View/Activity/Context from a ViewModel (causes memory leaks and untestable code).
- NEVER make API or database calls directly from a ViewModel (use Repository).
```

## ux-designer.md — Replace Protocol (Quality Gates)

```markdown
## Protocol (Quality Gates)
1. [Gate 1] (Prevents: exclusion of users with disabilities) Accessibility: TalkBack (Android) / VoiceOver (iOS) compatible, content descriptions on interactive elements, minimum contrast 4.5:1.
2. [Gate 2] (Prevents: unusable touch targets) Touch targets >= 48x48dp (Android) / 44x44pt (iOS), immediate visual feedback on tap, no gesture-only interactions without alternative.
3. [Gate 3] (Prevents: broken layout on real devices) Responsive: supports multiple screen sizes, handles orientation changes, respects system font size settings.

## Fatal Restrictions
- NEVER interactive elements smaller than 48x48dp / 44x44pt.
- NEVER rely solely on color to convey information.
- NEVER ignore system accessibility settings (font size, TalkBack/VoiceOver).
```

## performance-engineer.md — Replace Protocol (Quality Gates)

```markdown
## Protocol (Quality Gates)
1. [Gate 1] (Prevents: slow app startup) Cold start < 1s, warm start < 500ms.
2. [Gate 2] (Prevents: janky UI) Frame rate 60fps sustained, no dropped frames on scroll or animation.
3. [Gate 3] (Prevents: battery drain and crashes) No memory leaks (Activities, Fragments, ViewModels properly released), background work uses WorkManager/BGTaskScheduler, no unnecessary wake locks.

## Fatal Restrictions
- NEVER optimize without profiling first (Android Profiler / Xcode Instruments before changes).
- NEVER block the main/UI thread with network or database operations.
```

## orchestrator.md — Replace Flow 1 verification

In Flow 1, replace:
- `@architect (verifies e2e data flow between layers)` → `@architect (verifies ViewModel↔View separation and Repository pattern)`

## project-context.md — Add architecture field

Add to the Technical Decisions section:
```markdown
- Architecture: MVVM — [framework] (Android/iOS/Flutter), ViewModel + Repository pattern
```
