# staged_stepper

A staged, timed stepper widget with animated connecting bars. Useful for multi-phase operations like verification, confirmation, and completion.

<p align="center">
  <img src="https://raw.githubusercontent.com/<you>/staged_stepper/main/.github/demo.gif" alt="demo" width="600">
</p>

## Features
- N steps with individual durations
- Auto progression on timers
- Animated bar fill between steps
- Customizable circles and bars via builders
- Status titles per step and on completion
- Imperative control via `StagedStepperController`

## Install
```yaml
dependencies:
  staged_stepper: ^0.1.0
```
or
```bash
flutter pub add staged_stepper
```

## Quick start
```dart
final controller = StagedStepperController();

StagedStepper(
  controller: controller,
  steps: const [
    StagedStep(duration: Duration(seconds: 3), titleWhenActive: 'Checking...', titleWhenDone: 'Checked'),
    StagedStep(duration: Duration(seconds: 3), titleWhenActive: 'Confirming...', titleWhenDone: 'Confirmed'),
    StagedStep(duration: Duration(seconds: 3)),
  ],
  initialTitle: 'Checking...',
  finalTitle: 'Confirmed',
  circleBuilder: (ctx, state) => null, // default visuals
  barBuilder: (ctx, active) => null,   // default visuals
  onComplete: () { /* optional */ },
);
// later
controller.start();
```

## API

### `StagedStepper`
| Prop | Type | Default | Description |
|---|---|---|---|
| `steps` | `List<StagedStep>` | required | Ordered steps with durations and optional titles. |
| `initialTitle` | `String` | required | Title before first step finishes. |
| `finalTitle` | `String?` | `null` | Title after the last step completes. |
| `circleBuilder` | `Widget Function(BuildContext, StepState)` | required | Return `null` to use default rendering. |
| `barBuilder` | `Widget Function(BuildContext, bool)` | required | Return `null` to use default rendering. |
| `controller` | `StagedStepperController?` | `null` | Call `start()` to run. |
| `onComplete` | `VoidCallback?` | `null` | Called after the last step. |
| `barCurve` | `Curve` | `Curves.easeInOut` | Curve for bar fill animation. |
| `barFillDuration` | `Duration` | `600ms` | Duration for bar fill animation. |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(32)` | Outer padding. |
| `gap` | `double` | `8` | Horizontal gap around bars. |

### `StagedStep`
| Field | Type | Description |
|---|---|---|
| `duration` | `Duration` | How long this step “loads”. |
| `titleWhenActive` | `String?` | Title while this step is active. |
| `titleWhenDone` | `String?` | Title when this step finishes. |

### `StepState`
`waiting`, `loading`, `done`.

### `StagedStepperController`
- `Future<void> start()` — runs the sequence once.

## Customizing visuals
Provide builders. Return `null` to fallback to defaults.

```dart
circleBuilder: (ctx, state) {
  final cs = Theme.of(ctx).colorScheme;
  return switch (state) {
    StepState.waiting => Container(
      width: 30, height: 30,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cs.outline, width: 2)),
    ),
    StepState.loading => const SizedBox(
      width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5)),
    StepState.done => CircleAvatar(radius: 15, backgroundColor: cs.primary, child: Icon(Icons.check, size: 16, color: cs.onPrimary)),
  };
},
barBuilder: (ctx, active) => LayoutBuilder(
  builder: (_, c) => Stack(
    alignment: Alignment.centerLeft,
    children: [
      Container(height: 4, color: Theme.of(ctx).colorScheme.outline),
      AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        height: 4,
        width: active ? c.maxWidth : 0,
        color: Theme.of(ctx).colorScheme.primary,
      ),
    ],
  ),
),
```

## Example app
See `/example`. Run:
```bash
cd example
flutter run
```

## FAQ
**Can it autoplay?**  
Not yet. Use `controller.start()` in `initState` if you want immediate start.

**Multiple runs?**  
Rebuild a new `StagedStepper` or add a `reset()` in your fork. A controller `reset()` may land in a later minor version.

## Roadmap
- `autoplay` flag
- `reset()` and `jumpTo(int)`
- Vertical layout
- Accessibility hints per step
- Expose theming hooks: sizes, strokeWidth, colors in builders.
- Add onStepChange(int index, StepState state).

## License
MIT
