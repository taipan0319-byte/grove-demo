# GROVE — MVP Prototype

A gamified community wellness platform. Every health plan member is a growing oak
tree; wellness activity makes it grow. Trees aggregate into department groves,
groves into employer forests, forests into a regional civic ecosystem.

Built with Flutter (single codebase, iOS + Android). All data is stored locally —
no backend required for the prototype.

---

## Setup (one-time)

1. **Install the Flutter SDK** (3.x): https://docs.flutter.dev/get-started/install
   — Flutter was not detected on this machine, so this is a required step.
2. **Generate the platform folders.** This project ships all Dart source, pubspec,
   and tests; run this once in the project root to create `android/` and `ios/`
   (it only adds missing files, it never overwrites the app code):

   ```
   flutter create . --project-name grove --org com.grove
   ```

3. **Fetch dependencies and run:**

   ```
   flutter pub get
   flutter run
   ```

4. (Optional) `flutter test` runs the scoring-logic and boot smoke tests.

## Demo script (Mayor / investor flow)

Onboarding is pre-filled with Alex Johnson, Department of Public Works, City of
Rockford — three taps and you're in. Onboarding seeds a sample week of activity,
so Alex starts as a **Sapling (~28)**. Then, live on stage:

1. **Log Activity → Preventive → Flu Shot** (+75 pts)
2. **Log Activity → Physical → Workout, 60 min**

...and the stage-crossing celebration plays as the oak grows into a **Young
Tree**. Return to My Tree to watch the hero tree animate. Between demos, use
**Profile → Reset prototype data**.

## The Wellness Index

```
Index = Physical×0.35 + Nutrition×0.25 + Preventive×0.20 + Biometric×0.15 + Mental×0.05
```

- Each domain is scored 0–100 against a **weekly target** (e.g. 400 physical pts/wk).
- Points are **capped per day per domain** to prevent gaming (e.g. 100/day physical).
- Growth stages: Seedling 0–20 · Sapling 21–40 · Young Tree 41–60 ·
  Mature Tree 61–80 · Full Oak 81–100.

## Design decisions (made where the spec was open)

- **"Current week" = rolling 7-day window**, not calendar week — the score is
  meaningful on a Monday morning and demos are deterministic any day.
- **Onboarding seeds 3 days of sample logs** so the welcome seedling becomes a
  Sapling on entry and the grove/leaderboards look alive. Noted in the UI copy.
- **Marketplace balance = lifetime raw points + 500 welcome bonus** (separate
  from the normalized index), so redemption is demo-able on day one.
- **Mock community scores are fixed**, not re-randomized per launch, for
  repeatable demos; colleagues span all five tree stages.
- **Biometric "current" values** are prototype estimates nudged by logged
  milestones; the real product would use measured data.
- shared_preferences over Hive (no codegen, fewer moving parts), Provider over
  Riverpod (simplest fit for a single ChangeNotifier).

## Project structure

```
lib/
  main.dart                     app entry; routes to onboarding or shell
  models/                       user profile, activity catalog/logs, community, offers
  providers/app_state.dart      ChangeNotifier: state, scoring, persistence
  screens/                      onboarding, home (My Tree), log activity,
                                grove, forest, marketplace, profile
  utils/                        theme/palette, wellness calculator, mock data
  widgets/
    oak_tree.dart               the hero: CustomPainter oak renderer,
                                animated tree view, forest clusters
    grove_card.dart             shared warm card + section title
test/widget_test.dart           scoring logic + boot smoke tests
```

The oak renderer (`lib/widgets/oak_tree.dart`) draws every tree procedurally:
bezier trunk with root flare, deterministic overlapping canopy lobes in four
greens, branches that emerge with maturity, cast ground shadow, gold accent
leaves at Full Oak, and a gentle idle sway. One renderer powers the hero tree,
the member grove, and the employer forest clusters.
