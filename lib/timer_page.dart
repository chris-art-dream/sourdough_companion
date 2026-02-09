import 'package:flutter/material.dart';
import 'dart:async';

// Korrigierte Imports basierend auf deiner Dateistruktur
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
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _setupStep(0);
  }

  void _setupStep(int index) {
    if (index >= widget.recipe.steps.length) return;
    
    final step = widget.recipe.steps[index];
    setState(() {
      currentStepIndex = index;
      remainingSeconds = step.durationMinutes * 60;
      isRunning = false;
    });
    timer?.cancel();
  }

  void _toggleTimer() {
    if (isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _stopTimer();
        _showStepFinishedDialog();
      }
    });
  }

  void _stopTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void _showStepFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Schritt geschafft! 🥖'),
        content: const Text('Dein Teig ist bereit für den nächsten Schritt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Moment noch', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A4A32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _nextStep();
            },
            child: const Text('Weiter'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (currentStepIndex < widget.recipe.steps.length - 1) {
      _setupStep(currentStepIndex + 1);
    } else {
      Navigator.pop(context); // Zurück zur Übersicht, wenn fertig
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.recipe.steps[currentStepIndex];
    final progress = (currentStepIndex + 1) / widget.recipe.steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA), // Warmer, ruhiger Hintergrund
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.brown),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subtiler Fortschritt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.brown.withOpacity(0.05),
              color: Colors.brown.shade200,
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SCHRITT ${currentStepIndex + 1} VON ${widget.recipe.steps.length}',
            style: TextStyle(
              fontSize: 10, 
              letterSpacing: 1.5, 
              color: Colors.brown.withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Das Icon als visueller Ruhepol
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Icon(step.icon, size: 40, color: const Color(0xFF7A4A32)),
                  ),
                  const SizedBox(height: 32),
                  
                  // Titel & Anleitung
                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    step.detailedInstructions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Timer-Bereich (nur wenn Dauer > 0)
                  if (step.durationMinutes > 0) _buildTimerSection(),
                  
                  if (step.tip.isNotEmpty) _buildTipBox(step.tip),
                ],
              ),
            ),
          ),
          
          // Navigation unten
          _buildBottomBar(currentStepIndex == widget.recipe.steps.length - 1),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return GestureDetector(
      onTap: _toggleTimer,
      child: Column(
        children: [
          Text(
            _formatSeconds(remainingSeconds),
            style: const TextStyle(
              fontSize: 72, 
              fontWeight: FontWeight.w200, 
              letterSpacing: -2,
              color: Color(0xFF4E342E),
            ),
          ),
          Text(
            isRunning ? 'TIMER LÄUFT' : 'ZUM STARTEN TIPPEN',
            style: TextStyle(
              fontSize: 11, 
              letterSpacing: 1.2, 
              color: isRunning ? Colors.green : Colors.brown.withOpacity(0.4),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTipBox(String tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(tip, style: const TextStyle(fontSize: 14, color: Colors.brown, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isLastStep) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStepIndex > 0)
            TextButton(
              onPressed: () => _setupStep(currentStepIndex - 1),
              child: const Text('Zurück', style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          else
            const SizedBox(width: 80),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A4A32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            onPressed: isLastStep ? () => Navigator.pop(context) : _nextStep,
            child: Text(isLastStep ? 'Backen beenden' : 'Nächster Schritt', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatSeconds(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}