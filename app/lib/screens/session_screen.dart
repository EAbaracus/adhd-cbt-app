import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../theme/app_theme.dart';

/// Renders one session's checkpoints as a calm, sequential flow (I1).
/// Mutates the session's checkpoint states directly; the caller persists.
class SessionScreen extends StatefulWidget {
  final Session session;
  final void Function(Session)? onProgress;
  const SessionScreen({super.key, required this.session, this.onProgress});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int _index = 0;

  Checkpoint get _current => widget.session.checkpoints[_index];

  bool get _isLast => _index == widget.session.checkpoints.length - 1;

  void _complete() {
    _current.state = CheckpointState.completed;
    _advance();
  }

  void _defer() {
    _current.state = CheckpointState.deferred;
    _advance();
  }

  void _advance() {
    setState(() {
      if (_isLast) {
        widget.onProgress?.call(widget.session);
      } else {
        _index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.session.checkpoints.length) {
      return _completionCard();
    }
    final cp = _current;
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session ${widget.session.order}',
                style: AppText.caption.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(cp.title, style: AppText.h2),
              const SizedBox(height: AppTheme.spacing24),
              for (final para in cp.content) ...[
                Text(para, style: AppText.body),
                const SizedBox(height: AppTheme.spacing16),
              ],
              const SizedBox(height: AppTheme.spacing32),
              FilledButton(
                onPressed: _complete,
                child: Text(_isLast ? 'Finish session' : 'Done'),
              ),
              TextButton(
                onPressed: _defer,
                child: const Text('Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completionCard() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Harika, bir sonraki oturuma dön',
                    style: AppText.section, textAlign: TextAlign.center),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  'You are done with this session.',
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing32),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
