import 'package:jaspr/jaspr.dart';

import 'form_field.dart';
import 'form_path.dart';

/// A reactive form container that manages a collection of form fields.
///
/// Provides path-based access to nested fields, validation, and
/// value management for the entire form.
class Form extends ChangeNotifier {
  Form(Map<String, FormField> fields) : _root = FormGroup(fields) {
    // Set this form as the parent for all fields (enables cross-field validation)
    _root.parentForm = this;
    _root.addListener(_onRootChanged);
  }

  final FormGroup _root;

  void _onRootChanged() {
    notifyListeners();
  }

  /// Gets a field by path.
  ///
  /// Path formats:
  /// - "email" - direct field
  /// - "address.street" - nested group field
  /// - "items.[0]" - array element
  /// - "items.[0].name" - nested field in array element
  FormField? get(String path) {
    final formPath = FormPath.parse(path);
    return _root.getField(formPath);
  }

  /// Gets a typed field by path.
  ///
  /// Returns null if the field doesn't exist or isn't of type T.
  T? getField<T extends FormField>(String path) {
    final field = get(path);
    if (field is T) return field;
    return null;
  }

  /// Gets a control by path.
  ///
  /// Convenience method that returns null if the field isn't a FormControl.
  FormControl<T>? getControl<T>(String path) => getField<FormControl<T>>(path);

  /// Gets a group by path.
  ///
  /// Convenience method that returns null if the field isn't a FormGroup.
  FormGroup? getGroup(String path) => getField<FormGroup>(path);

  /// Gets an array by path.
  ///
  /// Convenience method that returns null if the field isn't a FormArray.
  FormArray<T>? getArray<T extends FormField>(String path) => getField<FormArray<T>>(path);

  /// Gets the current value of the entire form as a map.
  Map<String, dynamic> get value => _root.value;

  /// Sets values for the entire form.
  void setValue(Map<String, dynamic> value) {
    _root.setValue(value);
  }

  /// Patches specific values without affecting other fields.
  void patchValue(Map<String, dynamic> value) {
    _patchValue(_root, value);
  }

  void _patchValue(FormField field, dynamic value) {
    if (field is FormControl) {
      field.setValue(value);
    } else if (field is FormGroup && value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final child = field[entry.key];
        if (child != null) {
          _patchValue(child, entry.value);
        }
      }
    } else if (field is FormArray && value is List) {
      for (var i = 0; i < value.length && i < field.length; i++) {
        _patchValue(field[i], value[i]);
      }
    }
  }

  /// Gets all validation errors.
  Map<String, String> get errors => _root.errors;

  /// Returns true if the form is valid.
  bool get isValid => _root.isValid;

  /// Returns true if any field has been modified.
  bool get isDirty => _root.isDirty;

  /// Returns true if any field has been touched.
  bool get isTouched => _root.isTouched;

  /// Validates the entire form.
  /// Returns true if all fields are valid.
  bool validate() => _root.validate();

  /// Marks all fields as touched.
  void markAllAsTouched() => _root.markAllAsTouched();

  /// Resets the form to initial values or to the provided values.
  void reset([Map<String, dynamic>? value]) {
    _root.reset(value);
    notifyListeners();
  }

  /// Adds a field to the root group.
  void addField(String key, FormField field) {
    _root.addControl(key, field);
    notifyListeners();
  }

  /// Removes a field from the root group.
  void removeField(String key) {
    _root.removeControl(key);
    notifyListeners();
  }

  /// Checks if a field exists at the given path.
  bool contains(String path) => get(path) != null;

  /// Gets the keys of all root-level fields.
  Iterable<String> get keys => _root.keys;

  /// Gets all root-level fields.
  Iterable<FormField> get fields => _root.controls;

  @override
  void dispose() {
    _root.removeListener(_onRootChanged);
    _root.parentForm = null;
    _root.dispose();
    super.dispose();
  }
}
