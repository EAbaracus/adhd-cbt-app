enum ChunkTimerState { idle, running, paused, done }

class ChunkTimer {
  final int chunkMinutes;
  int _elapsed = 0;
  DateTime? startedAt;
  ChunkTimerState state = ChunkTimerState.idle;
  ChunkTimer(this.chunkMinutes);

  int get remainingSeconds => (chunkMinutes * 60) - _elapsed;
  int get elapsedSeconds => _elapsed;
  int get chunkSeconds => chunkMinutes * 60;

  void start() {
    if (state != ChunkTimerState.idle) return;
    startedAt = DateTime.now();
    state = ChunkTimerState.running;
  }

  void pause() {
    if (state != ChunkTimerState.running) return;
    state = ChunkTimerState.paused;
  }

  void resume() {
    if (state != ChunkTimerState.paused) return;
    state = ChunkTimerState.running;
  }

  void tick(int seconds) {
    if (state != ChunkTimerState.running) return;
    _elapsed = (_elapsed + seconds).clamp(0, chunkSeconds);
    if (_elapsed >= chunkSeconds) state = ChunkTimerState.done;
  }

  void finish() {
    if (state == ChunkTimerState.done) return;
    state = ChunkTimerState.done;
  }
}
