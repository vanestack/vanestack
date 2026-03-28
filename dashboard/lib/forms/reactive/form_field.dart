import 'package:jaspr/jaspr.dart';

import '../validators.dart';
import 'form.dart';
import 'form_path.dart';

/// Base class for all form field types.
///
/// Provides common functionality for value management, validation,
/// dirty/touched state, and change notification.
sealed class FormField extends ChangeNotifier {
  Form? _parentForm;

  /// The parent form this field belongs to, if any.
  /// Set automatically when the field is added to a Form.
  Form? get parentForm => _parentForm;

  /// Sets the parent form. Called internally by Form.
  set parentForm(Form? form) {
    _parentForm = form;
    _propagateFormToChildren(form);
  }

  /// Override in subclasses to propagate form reference to children.
  void _propagateFormToChildren(Form? form) {}

  /// Gets the current value of this field.
  dynamic get value;

  /// Sets the value of this field.
  void setValue(dynamic value);

  /// Gets all validation errors for this field and its children.
  /// Keys are paths relative to this field, values are error messages.
  Map<String, String> get errors;

  /// Returns true if this field and all children are valid.
  bool get isValid;

  /// Returns true if the value has been changed from its initial value.
  bool get isDirty;

  /// Returns true if the field has been touched (focused and blurred).
  bool get isTouched;

  /// Marks this field as touched.
  void markAsTouched();

  /// Marks this field and all children as touched.
  void markAllAsTouched();

  /// Validates this field and all children.
  /// Returns true if valid.
  bool validate();

  /// Resets this field to its initial value, or to the provided value.
  void reset([dynamic value]);

  /// Gets a child field by path.
  /// Returns null if the path doesn't exist.
  FormField? getField(FormPath path);
}

/// A form control for a single value.
class FormControl<T> extends FormField {
  FormControl({
    required T initialValue,
    List<Validator<T>> validators = const [],
  }) : _initialValue = initialValue,
       _value = initialValue,
       _validators = validators;

  final T _initialValue;
  T _value;
  final List<Validator<T>> _validators;

  String? _error;
  bool _isDirty = false;
  bool _isTouched = false;

  @override
  T get value => _value;

  /// The current validation error, if any.
  String? get error => _error;

  @override
  Map<String, String> get errors => _error != null ? {'': _error!} : {};

  @override
  bool get isValid => _error == null;

  @override
  bool get isDirty => _isDirty;

  @override
  bool get isTouched => _isTouched;

  @override
  void setValue(dynamic value) {
    if (value is! T) return;
    if (_value == value) return;

    _value = value;
    _isDirty = true;

    // Re-validate if there's already an error
    if (_error != null) {
      validate();
    }

    notifyListeners();
  }

  @override
  void markAsTouched() {
    if (!_isTouched) {
      _isTouched = true;
      notifyListeners();
    }
  }

  @override
  void markAllAsTouched() => markAsTouched();

  @override
  bool validate() {
    _error = null;

    for (final validator in _validators) {
      final result = validator(_value, _parentForm);
      if (result != null) {
        _error = result;
        notifyListeners();
        return false;
      }
    }

    notifyListeners();
    return true;
  }

  @override
  void reset([dynamic value]) {
    if (value != null && value is T) {
      _value = value;
    } else {
      _value = _initialValue;
    }
    _error = null;
    _isDirty = false;
    _isTouched = false;
    notifyListeners();
  }

  @override
  FormField? getField(FormPath path) {
    if (path.isEmpty) return this;
    return null; // Controls don't have children
  }
}

/// A form group containing a map of named fields.
class FormGroup extends FormField {
  FormGroup(Map<String, FormField> controls) : _controls = Map.from(controls) {
    // Listen to all child controls
    for (final control in _controls.values) {
      control.addListener(_onChildChanged);
    }
  }

  final Map<String, FormField> _controls;

  void _onChildChanged() {
    notifyListeners();
  }

  @override
  void _propagateFormToChildren(Form? form) {
    for (final control in _controls.values) {
      control.parentForm = form;
    }
  }

  /// Gets a control by key.
  FormField? operator [](String key) => _controls[key];

  /// Gets a typed control by key.
  ///
  /// Convenience method that returns null if the field isn't a FormControl.
  FormControl<T>? getControl<T>(String key) {
    final field = _controls[key];
    if (field is FormControl<T>) return field;
    return null;
  }

  /// Gets all control keys.
  Iterable<String> get keys => _controls.keys;

  /// Gets all controls.
  Iterable<FormField> get controls => _controls.values;

  /// Gets the number of controls.
  int get length => _controls.length;

  /// Adds a new control to the group.
  void addControl(String key, FormField control) {
    if (_controls.containsKey(key)) {
      _controls[key]!.removeListener(_onChildChanged);
      _controls[key]!.parentForm = null;
    }
    _controls[key] = control;
    control.parentForm = _parentForm;
    control.addListener(_onChildChanged);
    notifyListeners();
  }

  /// Removes a control from the group.
  void removeControl(String key) {
    final control = _controls.remove(key);
    if (control != null) {
      control.removeListener(_onChildChanged);
      control.parentForm = null;
      notifyListeners();
    }
  }

  /// Checks if the group contains a control with the given key.
  bool containsKey(String key) => _controls.containsKey(key);

  @override
  Map<String, dynamic> get value {
    final result = <String, dynamic>{};
    for (final entry in _controls.entries) {
      result[entry.key] = entry.value.value;
    }
    return result;
  }

  @override
  void setValue(dynamic value) {
    if (value is! Map<String, dynamic>) return;

    for (final entry in value.entries) {
      final control = _controls[entry.key];
      if (control != null) {
        control.setValue(entry.value);
      }
    }
  }

  /// Patches specific values without affecting other fields.
  ///
  /// Unlike setValue, this only updates fields that are present in the map.
  void patchValue(Map<String, dynamic> value) {
    for (final entry in value.entries) {
      final control = _controls[entry.key];
      if (control != null) {
        if (control is FormGroup && entry.value is Map<String, dynamic>) {
          control.patchValue(entry.value as Map<String, dynamic>);
        } else if (control is FormArray && entry.value is List) {
          for (var i = 0; i < (entry.value as List).length && i < control.length; i++) {
            final item = control[i];
            if (item is FormGroup && entry.value[i] is Map<String, dynamic>) {
              item.patchValue(entry.value[i] as Map<String, dynamic>);
            } else {
              item.setValue(entry.value[i]);
            }
          }
        } else {
          control.setValue(entry.value);
        }
      }
    }
  }

  @override
  Map<String, String> get errors {
    final result = <String, String>{};
    for (final entry in _controls.entries) {
      final childErrors = entry.value.errors;
      for (final errorEntry in childErrors.entries) {
        final path = errorEntry.key.isEmpty ? entry.key : '${entry.key}.${errorEntry.key}';
        result[path] = errorEntry.value;
      }
    }
    return result;
  }

  @override
  bool get isValid => _controls.values.every((c) => c.isValid);

  @override
  bool get isDirty => _controls.values.any((c) => c.isDirty);

  @override
  bool get isTouched => _controls.values.any((c) => c.isTouched);

  @override
  void markAsTouched() {
    for (final control in _controls.values) {
      control.markAsTouched();
    }
  }

  @override
  void markAllAsTouched() {
    for (final control in _controls.values) {
      control.markAllAsTouched();
    }
  }

  @override
  bool validate() {
    bool isValid = true;
    for (final control in _controls.values) {
      if (!control.validate()) {
        isValid = false;
      }
    }
    return isValid;
  }

  @override
  void reset([dynamic value]) {
    if (value is Map<String, dynamic>) {
      for (final entry in _controls.entries) {
        entry.value.reset(value[entry.key]);
      }
    } else {
      for (final control in _controls.values) {
        control.reset();
      }
    }
  }

  @override
  FormField? getField(FormPath path) {
    if (path.isEmpty) return this;

    final first = path.first;
    if (first is KeySegment) {
      final control = _controls[first.key];
      if (control == null) return null;
      return control.getField(path.rest);
    }
    return null;
  }

  @override
  void dispose() {
    for (final control in _controls.values) {
      control.removeListener(_onChildChanged);
    }
    super.dispose();
  }
}

/// A form array containing a list of fields.
class FormArray<T extends FormField> extends FormField {
  FormArray([List<T>? controls]) : _controls = controls?.toList() ?? [] {
    for (final control in _controls) {
      control.addListener(_onChildChanged);
    }
  }

  final List<T> _controls;

  void _onChildChanged() {
    notifyListeners();
  }

  @override
  void _propagateFormToChildren(Form? form) {
    for (final control in _controls) {
      control.parentForm = form;
    }
  }

  /// Gets a control by index.
  T operator [](int index) => _controls[index];

  /// Gets the number of controls.
  int get length => _controls.length;

  /// Returns true if the array is empty.
  bool get isEmpty => _controls.isEmpty;

  /// Returns true if the array is not empty.
  bool get isNotEmpty => _controls.isNotEmpty;

  /// Gets all controls.
  Iterable<T> get controls => _controls;

  /// Adds a control to the end of the array.
  void push(T control) {
    control.parentForm = _parentForm;
    control.addListener(_onChildChanged);
    _controls.add(control);
    notifyListeners();
  }

  /// Adds multiple controls to the end of the array.
  void pushAll(Iterable<T> controls) {
    for (final control in controls) {
      control.parentForm = _parentForm;
      control.addListener(_onChildChanged);
      _controls.add(control);
    }
    notifyListeners();
  }

  /// Inserts a control at the specified index.
  void insert(int index, T control) {
    control.parentForm = _parentForm;
    control.addListener(_onChildChanged);
    _controls.insert(index, control);
    notifyListeners();
  }

  /// Removes and returns the control at the specified index.
  T removeAt(int index) {
    final control = _controls.removeAt(index);
    control.removeListener(_onChildChanged);
    control.parentForm = null;
    notifyListeners();
    return control;
  }

  /// Removes all controls from the array.
  void clear() {
    for (final control in _controls) {
      control.removeListener(_onChildChanged);
      control.parentForm = null;
    }
    _controls.clear();
    notifyListeners();
  }

  /// Moves a control from one index to another.
  ///
  /// This is useful for reordering items in a list.
  void move(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    if (fromIndex < 0 || fromIndex >= _controls.length) return;
    if (toIndex < 0 || toIndex >= _controls.length) return;

    final item = _controls.removeAt(fromIndex);
    _controls.insert(toIndex, item);
    notifyListeners();
  }

  @override
  List<dynamic> get value => _controls.map((c) => c.value).toList();

  @override
  void setValue(dynamic value) {
    if (value is! List) return;

    // Update existing controls and add new ones if needed
    for (var i = 0; i < value.length && i < _controls.length; i++) {
      _controls[i].setValue(value[i]);
    }
  }

  @override
  Map<String, String> get errors {
    final result = <String, String>{};
    for (var i = 0; i < _controls.length; i++) {
      final childErrors = _controls[i].errors;
      for (final errorEntry in childErrors.entries) {
        final path = errorEntry.key.isEmpty ? '[$i]' : '[$i].${errorEntry.key}';
        result[path] = errorEntry.value;
      }
    }
    return result;
  }

  @override
  bool get isValid => _controls.every((c) => c.isValid);

  @override
  bool get isDirty => _controls.any((c) => c.isDirty);

  @override
  bool get isTouched => _controls.any((c) => c.isTouched);

  @override
  void markAsTouched() {
    for (final control in _controls) {
      control.markAsTouched();
    }
  }

  @override
  void markAllAsTouched() {
    for (final control in _controls) {
      control.markAllAsTouched();
    }
  }

  @override
  bool validate() {
    bool isValid = true;
    for (final control in _controls) {
      if (!control.validate()) {
        isValid = false;
      }
    }
    return isValid;
  }

  @override
  void reset([dynamic value]) {
    if (value is List) {
      for (var i = 0; i < _controls.length && i < value.length; i++) {
        _controls[i].reset(value[i]);
      }
    } else {
      for (final control in _controls) {
        control.reset();
      }
    }
  }

  @override
  FormField? getField(FormPath path) {
    if (path.isEmpty) return this;

    final first = path.first;
    if (first is IndexSegment) {
      if (first.index < 0 || first.index >= _controls.length) return null;
      final control = _controls[first.index];
      return control.getField(path.rest);
    }
    return null;
  }

  @override
  void dispose() {
    for (final control in _controls) {
      control.removeListener(_onChildChanged);
    }
    super.dispose();
  }
}
