___
# `exported` API

## Annotation `@exported`

The `@exported` annotation marks elements (libraries, classes, functions, 
constants, etc.) for inclusion in the generated barrel files.

For grouping, use tags that are defined via the `build.yaml` configuration.

### Usage:
```dart
// Adds the entire library to barrel files with 'core' tag or untagged files.
@Exported(tags: {'core'})
library;

// Adds a library with show combinators.
@Exported(tags: {'core'}, show: {'Foo'})
library;

// Adds a library with show combinators.
@Exported(tags: {'core'}, hide: {'Bar'})
library;

/// Adds a single element from a library to all barrel files.
@exported
class MyClass {}

// Adds a single element to matching barrel files.
@Exported(tags: ['models'])
void myFunction() {}

@Exported(tags: ['core'])
const String myConstant = 'some value';
```

## Configuration in `build.yaml`

### `barrel_files`

Defines the barrel files and associates tags with them. 
```yaml
targets:
  $default:
    builders:
      exported:
        options:
          barrel_files:
            # Custom barrel file 'lib/my_barrel_file.dart' including all
            # exports ('lib/' can be omitted)..
            - my_barrel_file.dart 
            # Default barrel file 'lib/$package.dart' including exports with
            # 'core' tag and untagged exports.
            - tags: 'core'
            # Custom barrel file 'lib/models/models.dart' with two tags. lib/models/models.dart with two tags
            - path: models/models.dart
              tags: ['core', 'models']
```

### `exports`

Defines additional exports (e.g., other packages), with optional tags to 
control in which barrel files the exports should be included.

Supports optional `show` and `hide` parameters to include or exclude specific
elements from the export.
```yaml
          exports:
            # Includes export of 'package:meta/meta.dart' in all barrel files.
            - foo
            # Includes export of 'package:$package/src/my_library.dart'.
            - lib/src/my_library.dart
            # Includes export of 'dart:async'.
            - dart:async
            # Includes export of 'package:bar/bar.dart' wth show combinators.
            - uri: bar
              show: ['Foo', 'bar']
            # Includes export of 'package:baz/baz.dart' wth hide combinators.
            - uri: baz
              hide: ['Baz']
            # Includes export in barrel files with `core`  or 'utils' tag or in
            # untagged barrel files.
            - uri: qux
              tags: ['core', 'utils']
```
___