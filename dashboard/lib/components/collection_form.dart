import 'package:vanestack_common/vanestack_common.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/collections.dart';
import '../utils/toast.dart';
import 'collection_form/attribute_row.dart';
import 'collection_form/index_row.dart';
import 'collection_form/rule_input.dart';
import 'progress_indicator.dart';
import 'sheet.dart';

enum CollectionFormTab { schema, indexes, rules }

enum CollectionFormType { base, view }

class CollectionForm extends StatefulComponent {
  final Collection? collection;
  CollectionForm({super.key, this.collection});
  @override
  State<StatefulComponent> createState() => _CollectionFormState();
}

class _CollectionFormState extends State<CollectionForm> {
  bool _saving = false;
  bool _deleting = false;
  int? _draggedIndex;
  int? _dragOverIndex;
  CollectionFormTab _activeTab = CollectionFormTab.schema;
  final Set<int> _expandedAttributes = {};
  CollectionFormType _collectionType = CollectionFormType.base;

  late final Form _form;

  bool get isEditing => component.collection != null;
  bool get isViewCollection => _collectionType == CollectionFormType.view;

  @override
  void initState() {
    super.initState();
    _form = _buildForm();
    _initializeFromCollection();
  }

  Form _buildForm() {
    return Form({
      'name': FormControl<String>(initialValue: '', validators: [required(), urlFriendly()]),
      'list_rule': FormControl<String?>(initialValue: null),
      'view_rule': FormControl<String?>(initialValue: null),
      'create_rule': FormControl<String?>(initialValue: null),
      'update_rule': FormControl<String?>(initialValue: null),
      'delete_rule': FormControl<String?>(initialValue: null),
      'view_query': FormControl<String>(initialValue: ''),
      'attributes': FormArray<FormGroup>([]),
      'indexes': FormArray<FormGroup>([]),
    });
  }

  FormArray<FormGroup> get _attributesArray => _form.getArray<FormGroup>('attributes')!;
  FormArray<FormGroup> get _indexesArray => _form.getArray<FormGroup>('indexes')!;

  FormGroup _createAttributeGroup(Attribute attr) {
    return FormGroup({
      'name': FormControl<String>(initialValue: attr.name),
      'type': FormControl<String>(initialValue: attr.type),
      'nullable': FormControl<bool>(initialValue: attr.nullable),
      'unique': FormControl<bool>(initialValue: attr.unique),
      'primary_key': FormControl<bool>(initialValue: attr.primaryKey),
      'default_value': FormControl<String>(initialValue: attr.defaultValue?.toString() ?? ''),
      'check_constraint': FormControl<String>(initialValue: attr.checkConstraint ?? ''),
      'foreign_key_table': FormControl<String>(initialValue: attr.foreignKey?.table ?? ''),
      'foreign_key_column': FormControl<String>(initialValue: attr.foreignKey?.column ?? ''),
      'foreign_key_on_delete': FormControl<String>(initialValue: attr.foreignKey?.onDelete ?? ''),
      'foreign_key_on_update': FormControl<String>(initialValue: attr.foreignKey?.onUpdate ?? ''),
    });
  }

  FormGroup _createIndexGroup(Index idx) {
    return FormGroup({
      'name': FormControl<String>(initialValue: idx.name),
      'columns': FormControl<String>(initialValue: idx.columns.join(', ')),
      'unique': FormControl<bool>(initialValue: idx.unique ?? false),
      'if_not_exists': FormControl<bool>(initialValue: idx.ifNotExists ?? false),
    });
  }

  Attribute _attributeFromGroup(FormGroup group) {
    final type = group.getControl<String>('type')!.value;
    final name = group.getControl<String>('name')!.value;
    final nullable = group.getControl<bool>('nullable')!.value;
    final unique = group.getControl<bool>('unique')!.value;
    final primaryKey = group.getControl<bool>('primary_key')!.value;
    final defaultValue = group.getControl<String>('default_value')!.value;
    final checkConstraint = group.getControl<String>('check_constraint')!.value;
    final fkTable = group.getControl<String>('foreign_key_table')!.value;
    final fkColumn = group.getControl<String>('foreign_key_column')!.value;
    final fkOnDelete = group.getControl<String>('foreign_key_on_delete')!.value;
    final fkOnUpdate = group.getControl<String>('foreign_key_on_update')!.value;

    final foreignKey = fkTable.isNotEmpty
        ? ForeignKey(
            table: fkTable,
            column: fkColumn.isNotEmpty ? fkColumn : 'id',
            onDelete: fkOnDelete.isNotEmpty ? fkOnDelete : null,
            onUpdate: fkOnUpdate.isNotEmpty ? fkOnUpdate : null,
          )
        : null;

    final baseParams = {
      'name': name,
      'nullable': nullable,
      'unique': unique,
      'primary_key': primaryKey,
      'default_value': defaultValue.isNotEmpty ? defaultValue : null,
      'check_constraint': checkConstraint.isNotEmpty ? checkConstraint : null,
      'foreign_key': foreignKey?.toJson(),
      'type': type,
    };

    return AttributeMapper.fromJson(baseParams);
  }

  Index _indexFromGroup(FormGroup group) {
    final name = group.getControl<String>('name')!.value;
    final columnsStr = group.getControl<String>('columns')!.value;
    final unique = group.getControl<bool>('unique')!.value;
    final ifNotExists = group.getControl<bool>('if_not_exists')!.value;

    return Index(
      name: name,
      columns: columnsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      unique: unique,
      ifNotExists: ifNotExists,
    );
  }

  List<Attribute> get _attributes => _attributesArray.controls.map(_attributeFromGroup).toList();
  List<Index> get _indexes => _indexesArray.controls.map(_indexFromGroup).toList();

  void _initializeFromCollection() {
    final col = component.collection;

    // Clear existing arrays
    _attributesArray.clear();
    _indexesArray.clear();

    if (col != null) {
      // Determine collection type from the sealed class
      _collectionType = col is ViewCollection ? CollectionFormType.view : CollectionFormType.base;

      _form.patchValue({
        'name': col.name,
        'list_rule': col.listRule,
        'view_rule': col.viewRule,
      });

      // Handle type-specific fields
      switch (col) {
        case BaseCollection():
          _form.patchValue({
            'create_rule': col.createRule,
            'update_rule': col.updateRule,
            'delete_rule': col.deleteRule,
          });
          for (final idx in col.indexes) {
            _indexesArray.push(_createIndexGroup(idx));
          }
        case ViewCollection():
          _form.patchValue({
            'view_query': col.viewQuery,
          });
      }

      for (final attr in col.attributes) {
        _attributesArray.push(_createAttributeGroup(attr));
      }
    } else {
      // Default to base collection for new collections
      _collectionType = CollectionFormType.base;

      // Add default system attributes for base collections
      _attributesArray.pushAll([
        _createAttributeGroup(
          TextAttribute(
            name: 'id',
            defaultValue: '(random_uuid_v7())',
            primaryKey: true,
            unique: true,
            nullable: false,
          ),
        ),
        _createAttributeGroup(
          DateAttribute(
            name: 'created_at',
            nullable: false,
            defaultValue: '(unixepoch())',
          ),
        ),
        _createAttributeGroup(
          DateAttribute(
            name: 'updated_at',
            nullable: false,
            defaultValue: '(unixepoch())',
          ),
        ),
      ]);
    }
  }

  @override
  void didUpdateComponent(covariant CollectionForm oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.collection != component.collection) {
      _initializeFromCollection();
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _setTab(CollectionFormTab tab) {
    // Prevent setting indexes tab for view collections
    if (tab == CollectionFormTab.indexes && isViewCollection) {
      return;
    }
    setState(() => _activeTab = tab);
  }

  void _addAttribute() {
    _attributesArray.push(
      _createAttributeGroup(
        TextAttribute(
          name: '',
          defaultValue: '',
          primaryKey: false,
          unique: false,
          nullable: true,
        ),
      ),
    );
  }

  void _addIndex() {
    _indexesArray.push(_createIndexGroup(Index(name: '', columns: [])));
  }

  void _removeAttribute(int index) {
    _attributesArray.removeAt(index);
    _expandedAttributes.remove(index);
  }

  void _removeIndex(int index) {
    _indexesArray.removeAt(index);
  }

  bool _isSystemAttribute(int index) {
    final group = _attributesArray[index];
    final name = group.getControl<String>('name')?.value ?? '';
    return ['id', 'created_at', 'updated_at'].contains(name);
  }

  List<String> _getAttributeNames() {
    final names = <String>[];
    for (var i = 0; i < _attributesArray.length; i++) {
      final group = _attributesArray[i];
      final name = group.getControl<String>('name')?.value ?? '';
      if (name.isNotEmpty) names.add(name);
    }
    return names;
  }

  void _reorderAttribute(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    final adjustedToIndex = toIndex > fromIndex ? toIndex - 1 : toIndex;
    _attributesArray.move(fromIndex, adjustedToIndex);
  }

  Future<void> _save() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      showToast(
        category: ToastCategory.error,
        title: 'Invalid form data',
      );
      return;
    }

    // Validate based on collection type
    if (isViewCollection) {
      final viewQuery = _form.getControl<String>('view_query')!.value;
      if (viewQuery.trim().isEmpty) {
        showToast(
          category: ToastCategory.error,
          title: 'Validation Error',
          description: 'View query is required for view collections',
        );
        return;
      }
    } else {
      final attributes = _attributes;
      final hasEmptyAttrName = attributes.any((attr) => attr.name.isEmpty);
      if (hasEmptyAttrName) {
        showToast(
          category: ToastCategory.error,
          title: 'Validation Error',
          description: 'All columns must have a name',
        );
        return;
      }
    }

    setState(() => _saving = true);

    final name = _form.getControl<String>('name')!.value;

    try {
      if (component.collection == null) {
        // Creating new collection
        if (isViewCollection) {
          await context
              .read(collectionsProvider.notifier)
              .createViewCollection(
                name: name,
                viewQuery: _form.getControl<String>('view_query')!.value,
                listRule: _form.getControl<String?>('list_rule')!.value,
                viewRule: _form.getControl<String?>('view_rule')!.value,
              );
        } else {
          final userAttributes = _attributes
              .where((attr) => !['id', 'created_at', 'updated_at'].contains(attr.name))
              .toList();
          await context
              .read(collectionsProvider.notifier)
              .createBaseCollection(
                name: name,
                attributes: userAttributes,
                indexes: _indexes,
                listRule: _form.getControl<String?>('list_rule')!.value,
                viewRule: _form.getControl<String?>('view_rule')!.value,
                createRule: _form.getControl<String?>('create_rule')!.value,
                updateRule: _form.getControl<String?>('update_rule')!.value,
                deleteRule: _form.getControl<String?>('delete_rule')!.value,
              );
        }
      } else {
        // Updating existing collection
        if (component.collection is ViewCollection) {
          await context
              .read(collectionsProvider.notifier)
              .updateViewCollection(
                collectionName: component.collection!.name,
                newName: name != component.collection!.name ? name : null,
                viewQuery: _form.getControl<String>('view_query')!.value,
                listRule: _form.getControl<String?>('list_rule')!.value,
                viewRule: _form.getControl<String?>('view_rule')!.value,
              );
        } else {
          final userAttributes = _attributes
              .where((attr) => !['id', 'created_at', 'updated_at'].contains(attr.name))
              .toList();
          await context
              .read(collectionsProvider.notifier)
              .updateBaseCollection(
                collectionName: component.collection!.name,
                newName: name != component.collection!.name ? name : null,
                attributes: userAttributes,
                indexes: _indexes,
                listRule: _form.getControl<String?>('list_rule')!.value,
                viewRule: _form.getControl<String?>('view_rule')!.value,
                createRule: _form.getControl<String?>('create_rule')!.value,
                updateRule: _form.getControl<String?>('update_rule')!.value,
                deleteRule: _form.getControl<String?>('delete_rule')!.value,
              );
        }
      }

      showToast(
        category: ToastCategory.success,
        title: 'Collection saved successfully',
      );

      Sheet.of(context)?.close();
      Router.of(context).push('/_/collections/$name');
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save collection',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await context.read(collectionsProvider.notifier).deleteCollection(component.collection!.name);

      showToast(
        category: ToastCategory.success,
        title: 'Collection deleted successfully',
      );

      Router.of(context).push('/_/collections');
      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete collection',
        description: e.message,
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  @override
  Component build(BuildContext context) {
    final collections = context.watch(collectionsProvider).value ?? [];
    return FormBuilder(
      form: _form,
      builder: (context, form) => Component.fragment([
        // Header
        div(
          classes: 'px-6 py-4 border-b border-border flex justify-between items-center bg-muted',
          [
            div([
              h2(classes: 'text-xl font-bold text-foreground', [
                Component.text(isEditing ? 'Edit Collection' : 'Create Collection'),
              ]),
              p(classes: 'text-xs text-muted-foreground mt-1', [
                Component.text(isEditing ? 'Modify schema, indexes and access rules' : 'Define your collection schema'),
              ]),
            ]),
            div(classes: 'flex gap-2', [
              if (isEditing)
                button(
                  id: 'deleteBtn',
                  classes: 'btn-icon-ghost hover:text-destructive',
                  events: events(onClick: _delete),
                  [
                    if (_deleting) const ProgressIndicator() else i(classes: 'icon-trash', []),
                  ],
                ),
              button(
                classes: 'btn-icon-ghost',
                events: events(onClick: () => Sheet.of(context)?.close()),
                [i(classes: 'icon-x', [])],
              ),
            ]),
          ],
        ),

        // Type selector (only shown when creating new collection)
        if (!isEditing)
          div(classes: 'px-6 py-4 border-b border-border bg-card', [
            label(classes: 'label grid gap-2', [
              span(classes: 'text-sm font-medium text-foreground', [Component.text('Collection Type')]),
              div(classes: 'grid grid-cols-2 gap-3', [
                _buildTypeCard(
                  type: CollectionFormType.base,
                  title: 'Base',
                  description: 'Store data in a database table',
                  icon: 'icon-table',
                ),
                _buildTypeCard(
                  type: CollectionFormType.view,
                  title: 'View',
                  description: 'Read-only view from SQL query',
                  icon: 'icon-eye',
                ),
              ]),
            ]),
          ]),

        // Collection name (always visible)
        div(classes: 'px-6 py-4 border-b border-border bg-card', [
          FormFieldBuilder<FormControl<String>>(
            path: 'name',
            builder: (context, field) => label(classes: 'label grid gap-2', [
              span(classes: 'text-sm font-medium text-foreground', [Component.text('Collection Name')]),
              input<String>(
                name: 'collectionName',
                classes: 'input',
                type: InputType.text,
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  'placeholder': 'e.g. posts, users, comments',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          ),
        ]),

        // Tab navigation - horizontally scrollable on mobile
        div(classes: 'px-6 border-b border-border bg-card overflow-x-auto', [
          div(key: ValueKey('tabBar_$isViewCollection'), classes: 'flex gap-1 min-w-max', [
            _buildTab('Schema', CollectionFormTab.schema, isViewCollection ? 'icon-code' : 'icon-table'),
            if (!isViewCollection) _buildTab('Indexes', CollectionFormTab.indexes, 'icon-key'),
            _buildTab('Access Rules', CollectionFormTab.rules, 'icon-shield'),
          ]),
        ]),

        // Tab content
        div(classes: 'flex-1 overflow-y-auto p-6 sheet-content', [
          if (_activeTab == CollectionFormTab.schema) _buildSchemaTab(collections),
          // Only show indexes tab for base collections
          if (_activeTab == CollectionFormTab.indexes && !isViewCollection) _buildIndexesTab(),
          if (_activeTab == CollectionFormTab.rules) _buildRulesTab(),
          // Fallback: if we're on indexes tab but it's a view collection, show schema
          if (_activeTab == CollectionFormTab.indexes && isViewCollection) _buildSchemaTab(collections),
        ]),

        // Footer
        div(
          classes: 'px-6 py-4 border-t border-border bg-muted flex justify-end gap-3',
          [
            button(
              classes: 'btn-outline',
              events: events(onClick: () => Sheet.of(context)?.close()),
              [Component.text('Cancel')],
            ),
            button(
              classes: 'btn',
              events: events(onClick: _save),
              disabled: _saving,
              [
                if (_saving) const ProgressIndicator() else i(classes: 'icon-check', []),
                Component.text(isEditing ? 'Save Changes' : 'Create Collection'),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  Component _buildTypeCard({
    required CollectionFormType type,
    required String title,
    required String description,
    required String icon,
  }) {
    final isSelected = _collectionType == type;
    return button(
      classes:
          'p-4 border rounded-lg text-left transition-all ${isSelected ? 'border-primary bg-primary/10 ring-2 ring-primary/20' : 'border-border hover:border-border hover:bg-muted'}',
      events: events(
        onClick: () {
          setState(() {
            _collectionType = type;
            // Reset to schema tab when changing type
            _activeTab = CollectionFormTab.schema;
            // Clear attributes when switching to view (they'll be inferred from query)
            if (type == CollectionFormType.view) {
              _attributesArray.clear();
              _indexesArray.clear();
            } else if (_attributesArray.isEmpty) {
              // Add default system attributes when switching to base
              _attributesArray.push(
                _createAttributeGroup(
                  TextAttribute(
                    name: 'id',
                    defaultValue: '(random_uuid_v7())',
                    primaryKey: true,
                    unique: true,
                    nullable: false,
                  ),
                ),
              );
              _attributesArray.push(
                _createAttributeGroup(
                  DateAttribute(
                    name: 'created_at',
                    nullable: false,
                    defaultValue: '(unixepoch())',
                  ),
                ),
              );
              _attributesArray.push(
                _createAttributeGroup(
                  DateAttribute(
                    name: 'updated_at',
                    nullable: false,
                    defaultValue: '(unixepoch())',
                  ),
                ),
              );
            }
          });
        },
      ),
      [
        div(classes: 'flex items-start gap-3', [
          div(
            classes:
                'w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${isSelected ? 'bg-primary/10' : 'bg-muted'}',
            [i(classes: '$icon ${isSelected ? 'text-primary' : 'text-muted-foreground'}', [])],
          ),
          div([
            div(classes: 'font-medium ${isSelected ? 'text-primary' : 'text-foreground'}', [Component.text(title)]),
            div(classes: 'text-xs ${isSelected ? 'text-primary' : 'text-muted-foreground'} mt-0.5', [
              Component.text(description),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildTab(String tabLabel, CollectionFormTab tab, String icon) {
    final isActive = _activeTab == tab;

    return button(
      classes:
          'px-4 py-3 text-sm font-medium transition-colors flex items-center gap-2 border-b-2 ${isActive ? 'border-primary text-primary' : 'border-transparent text-muted-foreground hover:text-foreground'}',
      events: events(onClick: () => _setTab(tab)),
      [
        i(classes: '$icon text-sm', []),
        Component.text(tabLabel),
        if (tab == CollectionFormTab.schema && !isViewCollection)
          span(
            classes:
                'ml-1 px-1.5 py-0.5 text-xs rounded-full ${isActive ? 'bg-primary/10 text-primary' : 'bg-muted text-muted-foreground'}',
            [Component.text('${_attributesArray.length}')],
          ),
        if (tab == CollectionFormTab.indexes && _indexesArray.isNotEmpty)
          span(
            classes:
                'ml-1 px-1.5 py-0.5 text-xs rounded-full ${isActive ? 'bg-primary/10 text-primary' : 'bg-muted text-muted-foreground'}',
            [Component.text('${_indexesArray.length}')],
          ),
      ],
    );
  }

  Component _buildSchemaTab(List<Collection> allCollections) {
    if (isViewCollection) {
      return _buildViewQueryEditor();
    }
    return _buildAttributesEditor(allCollections);
  }

  Component _buildViewQueryEditor() {
    return div(classes: 'space-y-4', [
      // Info banner
      div(classes: 'bg-primary/10 border border-primary/20 rounded-lg p-4 flex gap-3', [
        i(classes: 'icon-info text-primary mt-0.5', []),
        div([
          p(classes: 'text-sm text-primary font-medium', [Component.text('SQL View Query')]),
          p(classes: 'text-xs text-primary mt-1', [
            Component.text(
              'Define a SELECT query to create a read-only view. The query must include an "id" column and cannot contain INSERT, UPDATE, DELETE, DROP, CREATE, or ALTER statements.',
            ),
          ]),
        ]),
      ]),

      // View query textarea
      FormFieldBuilder<FormControl<String>>(
        path: 'view_query',
        builder: (context, field) => label(classes: 'label grid gap-2', [
          span(classes: 'text-sm font-medium text-foreground', [Component.text('Query')]),
          textarea(
            [Component.text(field.value)],
            name: 'viewQuery',
            classes: 'textarea font-mono text-sm min-h-[200px]',
            rows: 10,
            onInput: (v) => field.setValue(v),
            attributes: {
              'placeholder': '''SELECT
  posts.id,
  posts.title,
  count(comments.id) as total_comments
FROM posts
LEFT JOIN comments ON comments.post_id = posts.id
GROUP BY posts.id''',
            },
          ),
          if (field.isTouched && field.error != null)
            p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
        ]),
      ),

      // Example/tips
      div(classes: 'bg-muted border border-border rounded-lg p-4', [
        p(classes: 'text-sm text-muted-foreground font-medium mb-2', [Component.text('Tips')]),
        ul(classes: 'text-xs text-muted-foreground space-y-1 list-disc list-inside', [
          li([Component.text('The query result must include an "id" column')]),
          li([Component.text('Views are read-only - documents cannot be created, updated, or deleted')]),
          li([Component.text('Attributes will be automatically inferred from the query result')]),
          li([Component.text('Reference existing collections in your query using their table names')]),
        ]),
      ]),
    ]);
  }

  Component _buildAttributesEditor(List<Collection> allCollections) {
    return div(classes: 'space-y-3', [
      // Attribute cards
      for (var index = 0; index < _attributesArray.length; index++)
        AttributeRow(
          key: ValueKey('attr_$index'),
          index: index,
          isSystem: _isSystemAttribute(index),
          isDragOver: _dragOverIndex == index,
          isExpanded: _expandedAttributes.contains(index),
          allCollections: allCollections,
          onDelete: () => _removeAttribute(index),
          onToggleExpanded: () => setState(() {
            if (_expandedAttributes.contains(index)) {
              _expandedAttributes.remove(index);
            } else {
              _expandedAttributes.add(index);
            }
          }),
          onDragStart: () => setState(() => _draggedIndex = index),
          onDragOver: () => setState(() => _dragOverIndex = index),
          onDragEnd: () {
            if (_draggedIndex != null && _dragOverIndex != null) {
              _reorderAttribute(_draggedIndex!, _dragOverIndex!);
            }
            setState(() {
              _draggedIndex = null;
              _dragOverIndex = null;
            });
          },
        ),

      // Add column button
      button(
        classes:
            'w-full py-3 border border-dashed border-border rounded-lg text-muted-foreground hover:border-primary hover:text-primary hover:bg-primary/10 transition-colors flex items-center justify-center gap-2',
        events: events(onClick: _addAttribute),
        [
          i(classes: 'icon-plus', []),
          Component.text('Add Column'),
        ],
      ),
    ]);
  }

  Component _buildIndexesTab() {
    return div(classes: 'space-y-4', [
      // Info banner
      div(classes: 'bg-purple-50 border border-purple-200 rounded-lg p-4 flex gap-3', [
        i(classes: 'icon-info text-purple-500 mt-0.5', []),
        div([
          p(classes: 'text-sm text-purple-700 font-medium', [Component.text('Database Indexes')]),
          p(classes: 'text-xs text-purple-600 mt-1', [
            Component.text(
              'Indexes improve query performance for frequently accessed columns. Use unique indexes to enforce uniqueness constraints.',
            ),
          ]),
        ]),
      ]),

      // Index list
      if (_indexesArray.isEmpty)
        div(
          classes: 'text-center py-12 bg-muted rounded-lg border border-dashed border-border',
          [
            i(classes: 'icon-key text-3xl text-muted-foreground', []),
            p(classes: 'text-muted-foreground mt-2', [Component.text('No indexes defined')]),
            p(classes: 'text-muted-foreground text-sm', [Component.text('Add indexes to optimize query performance')]),
          ],
        )
      else
        div(classes: 'space-y-3', [
          for (var index = 0; index < _indexesArray.length; index++)
            IndexRow(
              key: ValueKey('idx_$index'),
              index: index,
              availableColumns: _getAttributeNames(),
              onDelete: () => _removeIndex(index),
            ),
        ]),

      // Add index button
      div(classes: 'pt-2', [
        button(
          classes: 'btn-secondary',
          events: events(onClick: _addIndex),
          [
            i(classes: 'icon-plus', []),
            Component.text('Add Index'),
          ],
        ),
      ]),
    ]);
  }

  Component _buildRulesTab() {
    return div(classes: 'space-y-6', [
      // Info banner
      div(classes: 'bg-warning/10 border border-warning/20 rounded-lg p-4 flex gap-3', [
        i(classes: 'icon-shield text-warning mt-0.5', []),
        div([
          p(classes: 'text-sm text-warning font-medium', [Component.text('Access Control Rules')]),
          p(classes: 'text-xs text-warning mt-1', [
            Component.text(
              isViewCollection
                  ? 'Define who can access this view collection. Leave empty to restrict access to superusers only. Views are read-only so only list and view rules apply.'
                  : 'Define who can access this collection. Leave empty to restrict access to superusers only. Use SQL expressions for custom rules.',
            ),
          ]),
        ]),
      ]),

      // Rules - show only list_rule and view_rule for view collections
      RuleInput(
        path: 'list_rule',
        ruleLabel: 'List Rule',
        description: 'Who can list documents in this collection',
        icon: 'icon-list',
      ),
      RuleInput(
        path: 'view_rule',
        ruleLabel: 'View Rule',
        description: 'Who can view individual documents',
        icon: 'icon-eye',
      ),
      if (!isViewCollection) ...[
        RuleInput(
          path: 'create_rule',
          ruleLabel: 'Create Rule',
          description: 'Who can create new documents',
          icon: 'icon-plus',
        ),
        RuleInput(
          path: 'update_rule',
          ruleLabel: 'Update Rule',
          description: 'Who can update existing documents',
          icon: 'icon-pencil',
        ),
        RuleInput(
          path: 'delete_rule',
          ruleLabel: 'Delete Rule',
          description: 'Who can delete documents',
          icon: 'icon-trash',
        ),
      ],
    ]);
  }
}
