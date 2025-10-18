import 'package:flutter/material.dart';
import 'package:staged_stepper/staged_stepper.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staged Stepper Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final controller = StagedStepperController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staged Stepper')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StagedStepper(
              controller: controller,
              steps: const [
                StagedStep(
                  duration: Duration(seconds: 3),
                  titleWhenActive: 'Checking...',
                  titleWhenDone: 'Checked',
                ),
                StagedStep(
                  duration: Duration(seconds: 3),
                  titleWhenActive: 'Confirming...',
                  titleWhenDone: 'Confirmed',
                ),
                StagedStep(duration: Duration(seconds: 3)),
              ],
              initialTitle: 'Checking...',
              finalTitle: 'Confirmed',
              // Use defaults for circle/bar builders. Pass null to keep defaults.
              circleBuilder: (ctx, state) => null,
              barBuilder: (ctx, active) => null,
              onComplete: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sequence finished')),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => controller.start(),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
