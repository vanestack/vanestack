/// SQLite reserved keywords that cannot be used as identifiers.
const _sqliteReservedKeywords = {
  'abort', 'action', 'add', 'after', 'all', 'alter', 'always', 'analyze',
  'and', 'as', 'asc', 'attach', 'autoincrement', 'before', 'begin', 'between',
  'by', 'cascade', 'case', 'cast', 'check', 'collate', 'column', 'commit',
  'conflict', 'constraint', 'create', 'cross', 'current', 'current_date',
  'current_time', 'current_timestamp', 'database', 'default', 'deferrable',
  'deferred', 'delete', 'desc', 'detach', 'distinct', 'do', 'drop', 'each',
  'else', 'end', 'escape', 'except', 'exclude', 'exclusive', 'exists',
  'explain', 'fail', 'filter', 'first', 'following', 'for', 'foreign', 'from',
  'full', 'generated', 'glob', 'group', 'groups', 'having', 'if', 'ignore',
  'immediate', 'in', 'index', 'indexed', 'initially', 'inner', 'insert',
  'instead', 'intersect', 'into', 'is', 'isnull', 'join', 'key', 'last',
  'left', 'like', 'limit', 'match', 'materialized', 'natural', 'no', 'not',
  'nothing', 'notnull', 'null', 'nulls', 'of', 'offset', 'on', 'or', 'order',
  'others', 'outer', 'over', 'partition', 'plan', 'pragma', 'preceding',
  'primary', 'query', 'raise', 'range', 'recursive', 'references', 'regexp',
  'reindex', 'release', 'rename', 'replace', 'restrict', 'returning', 'right',
  'rollback', 'row', 'rows', 'savepoint', 'select', 'set', 'table', 'temp',
  'temporary', 'then', 'ties', 'to', 'transaction', 'trigger', 'unbounded',
  'union', 'unique', 'update', 'using', 'vacuum', 'values', 'view', 'virtual',
  'when', 'where', 'window', 'with', 'without',
};

/// Validates that an identifier is URL-friendly and safe for SQL.
///
/// Must start with a lowercase letter and contain only lowercase letters,
/// numbers, and underscores. No spaces or special characters.
/// Rejects SQL reserved keywords to prevent conflicts.
bool isValidIdentifier(String identifier) {
  if (identifier.isEmpty) return false;
  final regex = RegExp(r'^[a-z][a-z0-9_]*$');
  if (!regex.hasMatch(identifier)) return false;

  // Reject SQL reserved keywords
  if (_sqliteReservedKeywords.contains(identifier.toLowerCase())) {
    return false;
  }

  return true;
}

bool isValidColumnType(String type) {
  final validTypes = [
    'TEXT',
    'INTEGER',
    'REAL',
    'BLOB',
    'NUMERIC',
    'VARCHAR',
    'CHAR',
    'BOOLEAN',
    'DATE',
    'DATETIME',
  ];
  return validTypes.contains(type.toUpperCase());
}
