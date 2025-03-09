// Copyright (c) 2025 Jannik Möser
// Use of this source code is governed by the BSD 3-Clause License.
// See the LICENSE file for full license information.

import 'package:exported_annotation/exported_annotation.dart';

@exported
class Class1 {
  void method() {}
}

@Exported(tags: {'foo', 'bar'})
void function1() {}

@exported
extension Class1Extension on Class1 {
  void extensionMethod() {}
}

@Exported(tags: {'bar'})
extension type Id(int id) {
  void extensionTypeMethod() {}
}

@exported
enum Enum1 { value1, value2 }

@exported
int get myNumber => 1;
