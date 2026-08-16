/// G2 completion-based state machine. Pure Dart, NO date logic (G2/G6).
library;

import 'models.dart';

class ProgramEngine {
  final List<Session> sessions;

  ProgramEngine(this.sessions);

  List<Session> get availableSessions =>
      sessions.where((s) => sessionState(s) != SessionState.locked).toList();

  Session? get currentSession {
    for (final s in sessions) {
      final st = sessionState(s);
      if (st == SessionState.inProgress || st == SessionState.available) return s;
    }
    return null;
  }

  Checkpoint? get currentCheckpoint {
    for (final s in sessions) {
      for (final c in s.checkpoints) {
        if (c.state == CheckpointState.completed || c.state == CheckpointState.deferred) {
          continue;
        }
        final unmet = c.requires.any((r) => !_isDone(s, r));
        if (!unmet) return c;
      }
    }
    return null;
  }

  bool _isDone(Session s, String cpId) {
    final cp = _findIn(s, cpId);
    return cp != null &&
        (cp.state == CheckpointState.completed || cp.state == CheckpointState.deferred);
  }

  Checkpoint? _findIn(Session s, String id) {
    for (final c in s.checkpoints) {
      if (c.id == id) return c;
    }
    return null;
  }

  void complete(String checkpointId) {
    _find(checkpointId)?.state = CheckpointState.completed;
  }

  void defer(String checkpointId) {
    _find(checkpointId)?.state = CheckpointState.deferred;
  }

  Checkpoint? _find(String checkpointId) {
    for (final s in sessions) {
      final c = _findIn(s, checkpointId);
      if (c != null) return c;
    }
    return null;
  }

  int completedCount(Session s) =>
      s.checkpoints.where((c) => c.state == CheckpointState.completed).length;

  SessionState sessionState(Session s) {
    final all = s.checkpoints.every((c) =>
        c.state == CheckpointState.completed || c.state == CheckpointState.deferred);
    if (all) return SessionState.completed;
    if (completedCount(s) > 0) return SessionState.inProgress;
    final earlier = sessions.where((x) => x.order < s.order);
    final anyEarlierStarted = earlier.any((x) => completedCount(x) > 0);
    if (earlier.isEmpty || anyEarlierStarted) return SessionState.available;
    return SessionState.locked;
  }
}
