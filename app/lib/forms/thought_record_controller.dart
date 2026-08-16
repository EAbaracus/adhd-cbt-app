import 'form_controller.dart';
import 'form_definition.dart';

class ThoughtRecordController extends FormController {
  ThoughtRecordController(super.form);

  List<String> get errorOptions {
    for (final f in form.fields) {
      if (f.id == 'thinking_error') return f.options;
    }
    return const [];
  }
}
