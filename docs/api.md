___
# `exported` API

## Annotation `@exported`

The `@exported` annotation marks elements (libraries, classes, functions, 
constants, etc.) for inclusion in the generated barrel files.

For grouping, use tags that are defined via the `build.yaml` configuration.

### Usage:
```dart
@Exported(tags: ['core']) // Added to barrel files with 'core' tag.
library;

@exported // Default, added to all barrel files.
class MyClass {}

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
            - tags: ['core'] # no path -> lib/<package>.dart
            - path: core.dart # lib/core.dart
              tags: ['core']
            - path: models/ # lib/models/<package>.dart
              # no tags -> added to all barrel files
            - path: models/models.dart # lib/models/models.dart
              tags: ['core', 'models']
            - path: lib/utils.dart # lib/utils.dart
              tags: ['core', 'utils']
```

### `exports`

Defines additional exports (e.g., other packages), with optional tags to 
control in which barrel files the exports should be included.

Supports optional `show` and `hide` parameters to include or exclude specific
elements from the export.
```yaml
          exports:
            # Includes all elements from package_a in all barrel files.
            - uri: package_a
            # Includes shown elements from package_a in all barrel files.
            - uri: package_a
              show: ['MyClass', 'myFunction']
            # Includes all but the hidden elements from package_a in all barrel
            # files.
            - uri: package_a
              hide: ['myConstant']
            # Includes export in barrel files with `core`  or 'utils' tag.
            - uri: package_b
              tags: ['core', 'utils']
```
___