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

### Key Features

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
- [Quick Start](#quick-start)
  - [Option 1: Annotating Individual Symbols](#option-1-annotating-individual-symbols)
  - [Option 2: Annotating a Library](#option-2-annotating-a-library)


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

Use `@exported` on individual classes, top-level functions, or constants:
```dart
import 'package:exported_annotation/exported_annotation.dart';

@exported
class MyClass {
  // Class definition
}
```

### Option 2: Annotating a Library

Use `@exported` on an entire library to include all contained public symbols:
```dart
@exported
library my_library;
```
You can control which symbols to include by using the `show` and `hide`
arguments of the annotation:
```dart
@Exported(show: {'MyClass'})
library my_library;

class MyClass {}
class MyOtherClass {}
```
In this example, the export directive that will be written into the barrel file
will only include `MyClass`:
```dart
export 'package:$package/$path_to/my_library.dart' show MyClass;
```


[barrel_files]: https://engineering.verygood.ventures/architecture/barrel_files/
[build_runner]: https://pub.dev/packages/build_runner
[build_runner_docs]: https://pub.dev/packages/build_runner#docs
[build_runner_getting_started]: https://pub.dev/packages/build_runner
[build_system]: https://github.com/dart-lang/build
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
[//]: # (## License)
[//]: # ()
[//]: # (How others can contribute to the project.)