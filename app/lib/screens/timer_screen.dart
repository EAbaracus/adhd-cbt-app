import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../timer/chunk_timer.dart';
import '../timer/timer_controller.dart';

class TimerScreen extends StatefulWidget {
  final TimerController controller;
  const TimerScreen({super.key, required this.controller});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const presets = [10, 15, 25, 45];
  ChunkTimer? _timer;
  Timer? _ticker;
  final _parkController = TextEditingController();
  final List<String> _parked = [];

  @override
  void initState() {
    super.initState();
    _recover();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _parkController.dispose();
    super.dispose();
  }

  Future<void> _recover() async {
    final last = await widget.controller.recoverLast();
    if (last != null && mounted) {
      setState(() => _timer = last);
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _timer?.tick(1));
    });
  }

  void _start(int minutes) {
    setState(() {
      _timer = ChunkTimer(minutes)..start();
    });
    _startTicker();
  }

  void _pause() {
    setState(() => _timer?.pause());
    _ticker?.cancel();
  }

  void _resume() {
    setState(() => _timer?.resume());
    _startTicker();
  }

  Future<void> _finish() async {
    final t = _timer;
    if (t == null) return;
    t.finish();
    _ticker?.cancel();
    await widget.controller.saveLog(t, distractions: _parked.length);
    if (!mounted) return;
    setState(() {
      _timer = null;
      _parked.clear();
    });
  }

  void _park() {
    final text = _parkController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _parked.add(text);
      _parkController.clear();
    });
  }

  String _fmt(int s) {
    final m = (s / 60).floor();
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = _timer;
    return Scaffold(
      appBar: AppBar(title: const Text('Focus timer')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            children: [
              if (t == null)
                Wrap(
                  spacing: AppTheme.spacing8,
                  children: [
                    for (final m in presets)
                      ChoiceChip(
                        label: Text('$m min'),
                        selected: false,
                        onSelected: (_) => _start(m),
                      ),
                  ],
                )
              else ...[
                Text(_fmt(t.remainingSeconds),
                    style: AppText.h1.copyWith(fontSize: 56)),
                const SizedBox(height: AppTheme.spacing24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (t.state == ChunkTimerState.running)
                      FilledButton(onPressed: _pause, child: const Text('Pause'))
                    else if (t.state == ChunkTimerState.paused)
                      FilledButton(
                          onPressed: _resume, child: const Text('Resume')),
                    const SizedBox(width: AppTheme.spacing16),
                    TextButton(onPressed: _finish, child: const Text('Finish')),
                  ],
                ),
              ],
              const SizedBox(height: AppTheme.spacing32),
              if (t != null) ...[
                const Divider(),
                const SizedBox(height: AppTheme.spacing8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Something pulling you away? Park it here.',
                      style: AppText.small.copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _parkController,
                        decoration:
                            const InputDecoration(hintText: 'Park a distraction'),
                        onSubmitted: (_) => _park(),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    TextButton(onPressed: _park, child: const Text('Park it')),
                  ],
                ),
                for (final p in _parked)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.push_pin_outlined, size: 18),
                    title: Text(p, style: AppText.small),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
