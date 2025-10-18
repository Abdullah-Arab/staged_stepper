library staged_stepper;

import 'dart:async';
import 'package:flutter/material.dart';

enum StepState { waiting, loading, done }

class StagedStep {
  final Duration duration; // how long this step "loads"
  final String? titleWhenActive;
  final String? titleWhenDone;
  const StagedStep({
    required this.duration,
    this.titleWhenActive,
    this.titleWhenDone,
  });
}

class StagedStepperController {
  VoidCallback? _start;
  Future<void> start() async => _start?.call();
}

class StagedStepper extends StatefulWidget {
  final List<StagedStep> steps;
  final String initialTitle;
  final String? finalTitle;
  final Widget Function(BuildContext, StepState) circleBuilder;
  final Widget Function(BuildContext, bool) barBuilder;
  final StagedStepperController? controller;
  final VoidCallback? onComplete;
  final Curve barCurve;
  final Duration barFillDuration;
  final EdgeInsetsGeometry padding;
  final double gap;

  const StagedStepper({
    super.key,
    required this.steps,
    required this.initialTitle,
    required this.circleBuilder,
    required this.barBuilder,
    this.controller,
    this.finalTitle,
    this.onComplete,
    this.barCurve = Curves.easeInOut,
    this.barFillDuration = const Duration(milliseconds: 600),
    this.padding = const EdgeInsets.all(32),
    this.gap = 8,
  });

  @override
  State<StagedStepper> createState() => _StagedStepperState();
}

class _StagedStepperState extends State<StagedStepper> {
  late List<StepState> states;
  late List<bool> bars;
  String? currentTitle;

  @override
  void initState() {
    super.initState();
    states = List.filled(widget.steps.length, StepState.waiting);
    states[0] = StepState.loading;
    bars = List.filled(widget.steps.length - 1, false);
    currentTitle = widget.steps.first.titleWhenActive ?? widget.initialTitle;
    widget.controller?._start = _run;
  }

  Future<void> _run() async {
    for (var i = 0; i < widget.steps.length; i++) {
      // wait for this step to “load”
      await Future.delayed(widget.steps[i].duration);
      if (!mounted) return;
      setState(() {
        states[i] = StepState.done;
        currentTitle = widget.steps[i].titleWhenDone ?? currentTitle;
      });

      // animate bar to next step and start next loading
      if (i < widget.steps.length - 1) {
        setState(() {
          bars[i] = true;
          states[i + 1] = StepState.loading;
          currentTitle = widget.steps[i + 1].titleWhenActive ?? currentTitle;
        });
        await Future.delayed(widget.barFillDuration);
      }
    }
    if (mounted) {
      setState(() => currentTitle = widget.finalTitle ?? currentTitle);
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget defaultCircle(StepState s) {
      switch (s) {
        case StepState.waiting:
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.outline, width: 3),
            ),
          );
        case StepState.loading:
          return const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          );
        case StepState.done:
          return CircleAvatar(
            radius: 14,
            backgroundColor: cs.primary,
            child: Icon(Icons.check, size: 16, color: cs.onPrimary),
          );
      }
    }

    Widget defaultBar(bool active) => LayoutBuilder(
      builder: (_, c) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(height: 4, color: cs.outline),
          AnimatedContainer(
            duration: widget.barFillDuration,
            curve: widget.barCurve,
            height: 4,
            width: active ? c.maxWidth : 0,
            color: cs.primary,
          ),
        ],
      ),
    );

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < states.length; i++) ...[
                widget.circleBuilder(context, states[i]) ??
                    defaultCircle(states[i]),
                if (i < states.length - 1) ...[
                  SizedBox(width: widget.gap),
                  Expanded(
                    child:
                        widget.barBuilder(context, bars[i]) ??
                        defaultBar(bars[i]),
                  ),
                  SizedBox(width: widget.gap),
                ],
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentTitle ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
