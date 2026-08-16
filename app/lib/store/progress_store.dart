abstract class ProgressStore {
  Future<Map<String, String>> load(); // checkpointId -> state name
  Future<void> save(Map<String, String> states);
}
