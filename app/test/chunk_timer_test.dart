import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/timer/chunk_timer.dart';

void main() {
  test('lifecycle idle->running->paused->resume->done', () {
    final t = ChunkTimer(25);
    expect(t.state, ChunkTimerState.idle);
    t.start();
    expect(t.state, ChunkTimerState.running);
    t.pause();
    expect(t.state, ChunkTimerState.paused);
    t.resume();
    expect(t.state, ChunkTimerState.running);
    t.finish();
    expect(t.state, ChunkTimerState.done);
  });

  test('pause freezes remaining, resume continues', () {
    final t = ChunkTimer(25);
    t.start();
    t.tick(10 * 60); // 10 min elapsed
    t.pause();
    final pausedAt = t.remainingSeconds;
    t.tick(5 * 60); // wall time passes while paused
    expect(t.remainingSeconds, pausedAt);
    t.resume();
    t.tick(2 * 60);
    expect(t.remainingSeconds, pausedAt - 2 * 60);
  });

  test('finish before zero is explicit, not forced', () {
    final t = ChunkTimer(10);
    t.start();
    t.finish(); // user chose to stop (planned pause, I1)
    expect(t.state, ChunkTimerState.done);
  });
}
