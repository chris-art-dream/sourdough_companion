import 'package:flutter/material.dart';
import 'dart:async';
import 'timer_service.dart';
import 'settings_service.dart';
import 'settings_page.dart';
import 'timer_model.dart';
import 'recipe_data.dart' as data;

class StepTimerPage extends StatefulWidget {
  final data.Recipe recipe;

  const StepTimerPage({super.key, required this.recipe});

  @override
  State<StepTimerPage> createState() => _StepTimerPageState();
}

class _StepTimerPageState extends State<StepTimerPage> {
  int currentStepIndex = 0;
  int remainingSeconds = 0;
  bool isRunning = false;
  bool autoAdvance = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadStep();
    // load auto-advance preference
    SettingsService.getAutoAdvance().then((v) {
      setState(() {
        autoAdvance = v;
      });
    });
  }

  void loadStep() {
    final step = widget.recipe.steps[currentStepIndex];
    setState(() {
      remainingSeconds = step.durationMinutes * 60;
      isRunning = false;
    });
  }

  void startPersistentTimer() async {
    final step = widget.recipe.steps[currentStepIndex];
    final endTime = DateTime.now()
        .add(Duration(minutes: step.durationMinutes))
        .millisecondsSinceEpoch;

    final runningTimer = RunningTimer(
      recipeTitle: widget.recipe.title,
      stepIndex: currentStepIndex,
      endTimestamp: endTime,
    );

    await TimerService.addTimer(runningTimer);
    setState(() {
      isRunning = true;
    });
    startLocalCountdown();
  }

  void startLocalCountdown() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          t.cancel();
          isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void stopTimer() async {
    timer?.cancel();
    await TimerService.removeTimerByRecipe(
        widget.recipe.title, currentStepIndex);
    setState(() {
      isRunning = false;
      remainingSeconds =
          widget.recipe.steps[currentStepIndex].durationMinutes * 60;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✅ Schritt abgeschlossen!'),
        content: const Text('Weiter zum nächsten Schritt?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (currentStepIndex < widget.recipe.steps.length - 1) {
                nextStep();
              }
            },
            child: const Text('Ja, nächster Schritt!'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Noch nicht'),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    if (h > 0) {
      return "$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  String displayTime() {
    if (isRunning) {
      // When running: show full minutes normally, but when under 60s show seconds
      if (remainingSeconds <= 60) {
        return formatTime(remainingSeconds);
      }

      final mins = (remainingSeconds + 59) ~/ 60;
      if (mins >= 60) {
        final h = mins ~/ 60;
        final m = mins % 60;
        if (m == 0) return '${h}h';
        return '${h}h ${m}min';
      }
      return '${mins} min';
    }

    return formatTime(remainingSeconds);
  }

  Future<void> nextStep() async {
    if (currentStepIndex < widget.recipe.steps.length - 1) {
      final wasRunning = isRunning;
      final oldIndex = currentStepIndex;

      setState(() {
        currentStepIndex++;
      });

      // load the new step; keep running flag as before
      final step = widget.recipe.steps[currentStepIndex];
      setState(() {
        remainingSeconds = step.durationMinutes * 60;
        if (!wasRunning) isRunning = false;
      });

      // cancel any local timer and restart if we were running
      timer?.cancel();

      // only auto-start if autoAdvance is enabled
      final shouldAutoStart = wasRunning && autoAdvance;

        if (shouldAutoStart) {
        // update persistent timer for the new step
        await TimerService.removeTimerByRecipe(widget.recipe.title, oldIndex);
        final endTime = DateTime.now()
            .add(Duration(minutes: step.durationMinutes))
            .millisecondsSinceEpoch;

        final runningTimer = RunningTimer(
          recipeTitle: widget.recipe.title,
          stepIndex: currentStepIndex,
          endTimestamp: endTime,
        );

        await TimerService.addTimer(runningTimer);
        isRunning = true;
        startLocalCountdown();
      } else {
        // ensure timer is stopped and not persisted
        isRunning = false;
        await TimerService.removeTimerByRecipe(widget.recipe.title, oldIndex);
      }
    }
  }

  void previousStep() {
    if (currentStepIndex > 0) {
      // If timer is running, ask user whether to continue timer on previous step
      if (isRunning) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Timer pausieren?'),
            content: const Text('Möchtest du den Timer beim vorherigen Schritt weiterlaufen lassen?'),
            actions: [
              TextButton(
                onPressed: () async {
                  // User chooses to continue timer on previous step
                  Navigator.pop(context);
                  final oldIndex = currentStepIndex;
                  setState(() {
                    currentStepIndex--;
                  });

                  // cancel any existing local timer and persistent timer for oldIndex
                    timer?.cancel();
                    await TimerService.removeTimerByRecipe(widget.recipe.title, oldIndex);

                  // start persistent timer for new step
                  final step = widget.recipe.steps[currentStepIndex];
                  final endTime = DateTime.now()
                      .add(Duration(minutes: step.durationMinutes))
                      .millisecondsSinceEpoch;

                  final runningTimer = RunningTimer(
                    recipeTitle: widget.recipe.title,
                    stepIndex: currentStepIndex,
                    endTimestamp: endTime,
                  );

                  await TimerService.addTimer(runningTimer);

                  setState(() {
                    remainingSeconds = step.durationMinutes * 60;
                    isRunning = true;
                  });

                  startLocalCountdown();
                },
                child: const Text('Ja, weiter'),
              ),
              TextButton(
                onPressed: () {
                  // User chooses to pause/stop timer and move to previous step
                  Navigator.pop(context);
                  setState(() {
                    currentStepIndex--;
                  });
                  timer?.cancel();
                  loadStep();
                },
                child: const Text('Nein, stoppen'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          currentStepIndex--;
        });

        timer?.cancel();
        loadStep();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final step = widget.recipe.steps[currentStepIndex];
    final isLastStep =
        currentStepIndex == widget.recipe.steps.length - 1;
    final progress =
        (currentStepIndex + 1) / widget.recipe.steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.brown.shade100,
                valueColor: AlwaysStoppedAnimation(Colors.brown.shade700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Schritt ${currentStepIndex + 1}/${widget.recipe.steps.length}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          step.icon,
                          size: 32,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📖 Anleitung',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            step.detailedInstructions,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.thermostat,
                          label: 'Temperatur',
                          value: step.temperature,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.schedule,
                          label: 'Dauer',
                          value: '${step.durationMinutes} Min',
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡 Tipp',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.tip,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: remainingSeconds <= 60
                          ? Colors.red.shade50
                          : Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: remainingSeconds <= 60
                            ? Colors.red
                            : Colors.brown.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          displayTime(),
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: remainingSeconds <= 60
                                ? Colors.red
                                : Colors.brown,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isRunning ? '⏱️ Timer läuft...' : '⏸️ Timer bereit',
                          style: TextStyle(
                            fontSize: 18,
                            color: isRunning ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          onPressed:
                              isRunning ? null : startPersistentTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text(
                            'Timer starten',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          onPressed: isRunning ? stopTimer : null,
                          icon: const Icon(Icons.stop),
                          label: const Text(
                            'Stoppen',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            disabledBackgroundColor: Colors.grey.shade200,
                          ),
                          onPressed:
                              currentStepIndex > 0 ? previousStep : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Zurück'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            disabledBackgroundColor: Colors.grey.shade200,
                          ),
                          onPressed: isLastStep ? null : nextStep,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(isLastStep
                              ? 'Fertig! 🎉'
                              : 'Nächster Schritt'),
                        ),
                      ),
                    ],
                  ),
                  if (isLastStep)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check_circle,
                              size: 24),
                          label: const Text(
                            'Backtag abschließen!',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
