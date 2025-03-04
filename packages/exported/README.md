[//]: # (TODO: Add badges - pub, build, coverage, etc.)

[Exported][exported] is a code generator that automates the creation and 
maintenance of barrel files using the [Dart build system][build_system].

[Barrel files][barrel_files] are a common pattern in [Dart packages][packages] 
to centralize a public API by re-exporting multiple library files through a 
single public file. Maintaining barrel files manually can be tedious and 
error-prone as codebases grow and public APIs change.

Exported simplifies this process by automatically generating barrel files based 
on annotations and configuration. Simply annotate top-level elements with
`@Exported`, and [build_runner][build_runner] will generate the appropriate
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
- [Run the Generator](#run-the-generator)
- [Quick Start](#quick-start)
  - [Option 1: Annotating Individual Symbols](#option-1-annotating-individual-symbols)
  - [Option 2: Annotating a Library](#option-2-annotating-a-library)
- [Further Configuration](#further-configuration)
  - [Adding Exports from the Builder Options](#adding-exports-from-the-builder-options)
  - [Multiple Barrel Files & Tagging](#multiple-barrel-files--tagging)
  - [Configuration Example](#configuration-example)


## Installation

Install [build_runner] and [exported] and [exported_annotation] by adding them
to your `pubspec.yaml` file:
```shell
dart pub add dev:build_runner
dart pub add dev:exported
dart pub add exported_annotation
```
This installs three packages:
- [build_runner][build_runner]: The tool that runs code generation (see:
  [Getting started with build_runner][build_runner_getting_started]).
- [exported][exported]: Provides the builders for generating barrel files.
- [exported_annotation][exported_annotation]: Contains the `@Exported` 
  annotation for marking elements for inclusion in barrel files.

  
## Run the Generator

To run the code generator, execute a one-time build in your project directory:
```shell
dart run build_runner build -d
```
Alternatively, run a persistent build server that watches your package files
for changes and rebuilds as necessary:
```shell
dart run build_runner watch -d
```
See the [build_runner documentation][build_runner_docs] for more information on
running builds.


## Quick Start

To get started, simply annotate top-level elements with `@exported` to include
them in the generated barrel file. Without further configuration, this will 
generate a file `lib/$package.dart` including all annotated symbols.

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

## Further Configuration

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


### Adding Exports from the Builder Options

In addition to annotating elements with `@exported`, you can specify additional
exports in the `exports` section of the builder options. This is primarily
useful for exporting symbols from external packages, but can also include
libraries from within your package.

#### External Package Exports

External libraries can be either `dart:` or `package:` libraries. You can
specify full URIs or simply use a package name:
```yaml
options:
  exports:
    - dart:async
    - package:uuid/uuid.dart
    - ecommerce_helpers # Resolves to package:ecommerce_helpers/ecommerce_helpers.dart
```
You can also use the `show` and `hide` arguments to filter which symbols to
include:
```yaml
options:
  exports:
    - dart:async
    - uri: package:uuid/uuid.dart
      show: ['Uuid']
    - uri: ecommerce_helpers
      hide: ['LegacyUserHelper', 'LegacyOrderHelper']
```
This example will generate:
```dart
export 'dart:async';
export 'package:uuid/uuid.dart' show Uuid;
export 'package:ecommerce_helpers/ecommerce_helpers.dart' hide LegacyUserHelper, LegacyOrderHelper;
```

#### Internal Library Exports

To include symbols from libraries within your own package, use the `uri`
argument with a relative path starting with `lib/`:
```yaml
options:
  exports:
    - lib/src/api.dart
    - uri: lib/src/models/user.dart
      show: ['User']
```
Which generates:
```dart
export 'package:ecommerce/src/api.dart';
export 'package:ecommerce/src/models/user.dart' show User;
```

> [!WARNING]
> When duplicate export URIs are configured for a barrel file (via annotations
> and/or builder options), show/hide filters will be merged cumulatively.
> - An export of the entire library will override any show/hide filters.
> - A hide filter that shows everything besides the hidden elements will
>   override a show filter that only shows specific elements.
> - If an element is both shown and hidden, it will be shown.

### Multiple Barrel Files & Tagging

[//]: # (Explain how to configure multiple barrel files using tags.)

[//]: # (Demonstrate how to assign different exports to specific barrel files)
[//]: # (using tags.)

[//]: # (Provide an example of a build.yaml configuration with multiple barrel )
[//]: # (files and their corresponding tags.)


### Configuration Example

[//]: # (Provide a complete example of a build.yaml configuration file, including)
[//]: # (multiple barrel files, tagging, and external package exports. This will)
[//]: # (give users a clear template to work with.)


[barrel_files]: https://engineering.verygood.ventures/architecture/barrel_files/
[build_runner]: https://pub.dev/packages/build_runner
[build_runner_docs]: https://pub.dev/packages/build_runner#docs
[build_runner_getting_started]: https://github.com/dart-lang/build/blob/master/docs/getting_started.md
[build_system]: https://github.com/dart-lang/build
[build_yaml]: https://github.com/dart-lang/build/blob/master/docs/build_yaml_format.md
[exported]: https://pub.dev/packages/exported
[exported_annotation]: https://pub.dev/packages/exported_annotation
[packages]: https://dart.dev/tools/pub/packages



[//]: # (## Usage)
[//]: # ()
[//]: # (A deeper dive into tagging, multiple barrel files, and additional exports.)
[//]: # ()
[//]: # (## Contributing)
[//]: # ()
[//]: # (How others can contribute to the project.)
[//]: # ()