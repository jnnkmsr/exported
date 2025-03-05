[//]: # (TODO: Add badges - pub, build, coverage, etc.)
[//]: # (TODO: Add links to API, e.g., for @Exported)

[Exported][exported] is a code generator that automates the creation and 
maintenance of barrel files using the [Dart build system][build_system].

[Barrel files][barrel_files] are a common pattern in [Dart packages][packages] 
to centralize a public API by re-exporting multiple library files through a 
single public file. Maintaining barrel files manually can be tedious and 
error-prone as codebases grow and public APIs change.

Exported simplifies this process by automatically generating barrel files based 
on annotations and configuration. Simply annotate top-level elements with
`@Exported`, and [`build_runner`][build_runner] will generate the appropriate
barrel files, ensuring your public API stays up-to-date with minimal effort. 

### Features

- **Annotation-Based Exports**: Use the `@Exported` annotation on library
  directives, classes, functions, or other top-level elements to include them
  in barrel files.
- **Option-Based Exports**: Include additional exports (e.g., symbols from
  other packages) via the `build.yaml` configuration.
- **Multiple Barrel Files**: Generate multiple barrel files for different parts 
  of your package.
- **Export Tagging**: Easily organize exports using tags for grouping and 
  mapping them to specific barrel files.


## Contents

- [Installation](#installation)
- [Running the Generator](#running-the-generator)
- [Quick Start](#quick-start)
  - [Option 1: Annotating Individual Symbols](#option-1-annotating-individual-symbols)
  - [Option 2: Annotating a Library](#option-2-annotating-a-library)
- [Configuration of Builder Options](#configuration-of-builder-options)
- [Adding Exports from the Builder Options](#adding-exports-from-the-builder-options)
  - [External Package Exports](#external-package-exports)
  - [Internal Library Exports](#internal-library-exports)
- [Customizing Barrel Files](#customizing-barrel-files)
  - [Changing the Barrel-File Path](#changing-the-barrel-file-path)
  - [Setting Up Multiple Barrel Files](#setting-up-multiple-barrel-files)
  - [Assigning Export Tags](#assigning-export-tags)


## Installation

Install [`build_runner`][build_runner], [`exported`][exported] and
[`exported_annotation`][exported_annotation] by adding them  to your 
`pubspec.yaml` file:
```shell
dart pub add dev:build_runner
dart pub add dev:exported
dart pub add exported_annotation
```

  
## Running the Generator

To run the code generator, execute a one-time build in your project directory:
```shell
dart run build_runner build -d
```
Alternatively, run a persistent build server that watches your package files
for changes and rebuilds as necessary:
```shell
dart run build_runner watch -d
```
See the [`build_runner` documentation][build_runner_docs] for more information
on running builds.


## Quick Start

To get started, simply annotate top-level elements with `@exported` to include
them in the generated barrel file. By default, this will generate a file 
`lib/$package.dart` that includes all annotated symbols.

### Option 1: Annotating Individual Symbols

Use `@exported` on individual classes (or any other public top-level element):
```dart
import 'package:exported_annotation/exported_annotation.dart';

@exported
class User {}

@exported
class Order {}

class Payment {}
```
The generated barrel file (e.g., `lib/ecommerce.dart`) will export `User` and
`Order`:
```dart
export 'package:ecommerce/src/models.dart' show User, Order;
```

### Option 2: Annotating a Library

Use `@exported` on an entire library to include all contained public symbols:
```dart
@exported
library;

class User {}
class Order {}
class Payment {}
```
This will generate an export directive of the entire library:
```dart
export 'package:ecommerce/src/models.dart';
```

#### Show and Hide Combinators

You can control which symbols to include by using the `show` and `hide`
arguments of the annotation:
```dart
// Exports User and Order, while excluding Payment.
@Exported(show: {'User', 'Order'})
library;

class User {}
class Order {}
class Payment {}
```
Which generates:
```dart
export 'package:ecommerce/src/models.dart' show User, Order;
```
Similarly, use `hide`:
```dart
@Exported(hide: {'Payment'})
library;

class User {}
class Order {}
class Payment {}
```
Generating:
```dart
export 'package:ecommerce/src/models.dart' hide Payment;
```


## Configuration of Builder Options

Exported uses the [`build.yaml` configuration file][build_yaml] to customize
how barrel files are generated, including:
- **Adding additional exports** of external packages or libraries within your 
  package.
- **Configuring multiple barrel files** and using **tags** to control which
  exports go into each file.

The `build.yaml` file should be placed at the root of your package, alongside
`pubspec.yaml`:
```
my_package/
  lib/
  build.yaml
  pubspec.yaml
```
Configure the `exported` builder options by following the standard structure
used by Dart's build system:
```yaml
targets:
  $default:
    builders:
      exported:
        options:
          # Configuration options
```


## Adding Exports from the Builder Options

In addition to annotating elements with `@exported`, you can specify additional
exports in the `exports` section of the builder options. This is primarily
useful for exporting symbols from external packages, but can also include
libraries from within your package.

### External Package Exports

External libraries can be either `dart:` or `package:` libraries. You can
specify full URIs or simply use a package name:
```yaml
options:
  exports:
    - 'dart:async'
    - 'package:uuid/uuid.dart'
    - 'ecommerce_helpers' # Resolves to 'package:ecommerce_helpers/ecommerce_helpers.dart'
```
Use the `show` and `hide` filters to selectively export only specific symbols 
from the package:
```yaml
options:
  exports:
    - 'dart:async'
    - uri: 'package:uuid/uuid.dart'
      show: ['Uuid']
    - uri: 'ecommerce_helpers'
      hide: ['LegacyUserHelper', 'LegacyOrderHelper']
```
This example will generate:
```dart
export 'dart:async';
export 'package:uuid/uuid.dart' show Uuid;
export 'package:ecommerce_helpers/ecommerce_helpers.dart' hide LegacyUserHelper, LegacyOrderHelper;
```

### Internal Library Exports

To include symbols from libraries within your own package, use the `uri`
argument with a relative path starting with `lib/`:
```yaml
options:
  exports:
    - 'lib/src/api.dart'
    - uri: 'lib/src/models/user.dart'
      show: ['User']
```
Which generates:
```dart
export 'package:ecommerce/src/api.dart';
export 'package:ecommerce/src/models/user.dart' show User;
```

> [!WARNING]
> When duplicate export URIs are configured (via annotations and/or builder 
> options), Exported will silently merge the show/hide filters per barrel file:
> - If a library is exported in full (without filters), it will override any 
>   `show` or `hide` filters.
> - A `hide` filter takes precedence over a `show` filter (i.e., anything
>   excluded implicitly by `show` will be included through `hide`).
> - If an element is both shown and hidden, it will be shown.


## Customizing Barrel Files

By default, Exported generates a single barrel file `lib/$package.dart`. This
can be customized from the `barrel_files` section of the builder options.

### Changing the Barrel-File Path

To change the path of the generated barrel file, specify a different file path
relative to the package root:
```yaml
options:
  barrel_files:
    - 'lib/core.dart'
```

### Setting Up Multiple Barrel Files

Exported allows you to generate multiple barrel files for a package. The
generator uses a tagging system to group exports and map them to specific
barrel files. To use multiple barrel files, configure them in the `build.yaml`:
```yaml
options:
  barrel_files:
    - 'lib/ecommerce.dart'
    - path: 'lib/core.dart'
      tags: ['core']
    - path: 'lib/models.dart'
      tags: ['models']
```
In this example, three barrel files will be generated:
- `lib/ecommerce.dart` will contain all exports.
- `lib/core.dart` will contain exports tagged with `core`.
- `lib/models.dart` will contain exports tagged with `models`.

> [!INFO]
> If the `path` is omitted, the default barrel-file path `lib/$package.dart`
> will be used for that file.

### Assigning Export Tags

To assign tags to exports, use the `tags` parameter of `@Exported`:
```dart
import 'package:exported_annotation/exported_annotation.dart';

@Exported(tags: {'core'})
class User {}

@Exported(tags: {'models'})
class Order {}

@exported
class Payment {}
```
In this example:
- `lib/ecommerce.dart` will export all three symbols.
- `User` and `Order` will be exported to `lib/core.dart` and `lib/models.dart`,
  respectively.
- `Payment` is untagged and will be exported to *all* barrel files.

Tags can be reused across multiple barrel files and each export can be assigned
multiple tags, allowing for flexible grouping of exports.

> [!IMPORTANT]
> - Exports without tags will be included in all barrel files.
> - Barrel files without tags will include all exports, regardless of their 
>   tags.

For exports that are added via the builder options, use the `tags` key:
```yaml
options:
  exports:
    - uri: 'package:uuid/uuid.dart'
      tags: ['core']
    - uri: 'lib/src/models/user.dart'
      show: ['User']
      tags: ['models']
```


[barrel_files]: https://engineering.verygood.ventures/architecture/barrel_files/
[build_runner]: https://pub.dev/packages/build_runner
[build_runner_docs]: https://pub.dev/packages/build_runner#docs
[build_system]: https://github.com/dart-lang/build
[build_yaml]: https://github.com/dart-lang/build/blob/master/docs/build_yaml_format.md
[exported]: https://pub.dev/packages/exported
[exported_annotation]: https://pub.dev/packages/exported_annotation
[packages]: https://dart.dev/tools/pub/packages
