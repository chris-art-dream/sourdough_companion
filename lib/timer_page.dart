import 'package:flutter/material.dart';
import 'dart:async';
import 'recipe_model.dart';

class StepTimerPage extends StatefulWidget {
  final Recipe recipe;
  const StepTimerPage({super.key, required this.recipe});

  @override
  State<StepTimerPage> createState() => _StepTimerPageState();
}

class _StepTimerPageState extends State<StepTimerPage> {
  int _currentStepIndex = 0;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = minutes * 60;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() => _isTimerRunning = false);
        _showTimerFinishedDialog();
      }
    });
  }

  void _showTimerFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Zeit abgelaufen! 🔔"),
        content: const Text("Dein Teig hat genug geruht. Weiter geht's zum nächsten Schritt!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A4A32))),
          ),
        ],
      ),
    );
  }

  // Formatiert Sekunden in hh:mm:ss oder mm:ss
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Kurze Textanzeige für die Gesamtdauer
  String _formatDurationText(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '$minutes Min';
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.recipe.steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / widget.recipe.steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF7A4A32),
            minHeight: 8,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text("${_currentStepIndex + 1}/${widget.recipe.steps.length}", 
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title.toUpperCase(),
                      style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Color(0xFF7A4A32), fontSize: 13)),
                  const SizedBox(height: 12),
                  Text(step.detailedInstructions,
                      style: const TextStyle(fontSize: 20, height: 1.5, color: Color(0xFF2D1B14))),
                  const SizedBox(height: 32),
                  
                  // TIMER CARD
                  if (step.durationMinutes > 0)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15)],
                        border: Border.all(color: _isTimerRunning ? const Color(0xFF7A4A32) : Colors.transparent),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Empfohlene Dauer", style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(_formatDurationText(step.durationMinutes), style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isTimerRunning 
                                ? _formatTime(_secondsRemaining) 
                                : _formatTime(step.durationMinutes * 60),
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _startTimer(step.durationMinutes),
                              icon: Icon(_isTimerRunning ? Icons.refresh : Icons.play_arrow),
                              label: Text(_isTimerRunning ? "Timer neustarten" : "Timer starten"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isTimerRunning ? Colors.grey.shade100 : const Color(0xFF7A4A32),
                                foregroundColor: _isTimerRunning ? Colors.black87 : Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // INFO BOX (Nur anzeigen, wenn Technik-Erklärung vorhanden)
                  if (step.techniqueExplanation != null)
                    _buildInfoBox("Warum machen wir das?", step.techniqueExplanation!, Icons.lightbulb_outline, Colors.amber.shade800),
                  
                  // Temperatur-Info (Optionaler Check)
                  if (step.temperature != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoBox("Temperatur-Hinweis", "Achte auf eine Umgebungstemperatur von ca. ${step.temperature}.", Icons.thermostat, Colors.blueGrey),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withAlpha(10), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade800, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
      ),
      child: Row(
        children: [
          if (_currentStepIndex > 0)
            IconButton(
              onPressed: () {
                _timer?.cancel();
                setState(() { 
                  _currentStepIndex--; 
                  _isTimerRunning = false; 
                });
              },
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_currentStepIndex < widget.recipe.steps.length - 1) {
                  _timer?.cancel();
                  setState(() { 
                    _currentStepIndex++; 
                    _isTimerRunning = false; 
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A4A32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(_currentStepIndex < widget.recipe.steps.length - 1 ? "Schritt erledigt" : "Backen abschließen"),
            ),
          ),
        ],
      ),
    );
  }
}