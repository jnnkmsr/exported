# `exported` API Review

## 1. Annotation Naming and Consistency

- **Case Consistency:**
  In the documentation, the annotation is sometimes shown as `@Exported` and
  other times as `@exported`. In Dart it’s common to name annotation classes
  with an uppercase first letter. If you want the convenience of a lowercase
  constant (for example, defining a top‑level `const exported = Exported();`),
  document that pattern clearly. Otherwise, pick one style and be consistent
  throughout the docs.

- **Naming Alternatives:**
  Consider whether the name `Exported` is the most descriptive. (Some projects
  use names like `@Export` or `@BarrelExport` to make it clear what role the
  annotation plays.) This is a minor point, but it may help avoid confusion
  with Dart’s native export syntax.

---

## 2. Tag Semantics and Default Behavior

- **Default Inclusion:**
  Currently, if no tags are specified on an annotated element, it’s added to
  *all* barrel files. This is a flexible default, but might be counterintuitive
  for users who expect an element to be “opt‑in” only for certain barrels. One
  possible improvement is to let users configure a “default” tag (or even
  require an explicit tag) so that inclusion in a barrel file is always
  deliberate.

- **Explicit Default Barrel:**
  Alternatively, if the intent is to always have one “catch‑all” barrel file
  (like `lib/<package>.dart`), you might allow users to mark that barrel file
  as the default and have untagged elements go there only. This would make the
  behavior more predictable when working with multiple barrel files.

---

## 3. Barrel File Configuration

- **Naming vs. Paths:**
  Currently, the configuration relies on inferring the barrel file’s name from
  its `path` (or defaulting to `lib/<package>.dart` when no path is provided).
    - **Suggestion:** Allow an optional `name` property for each barrel file
      configuration. This name could then be used in error messages, debugging,
      or even as part of a more advanced API where barrel files reference one
      another.

- **Path Handling:**
  The example with `path: models/` implies that if a trailing slash is present,
  the file will be named after the package (i.e. `lib/models/<package>.dart`).
    - **Improvement:** Document this behavior explicitly in the API docs so that
      users aren’t surprised by the file naming convention. Alternatively,
      consider requiring an explicit file name (even if it’s generated from a
      template) to avoid ambiguity.

---

## 4. External Exports Configuration

- **`show` vs. `hide`:**
  It’s very useful to mirror Dart’s own export syntax by allowing `show` and
  `hide`.
    - **Validation:** Ensure that the generator enforces that both options are
      not provided simultaneously, as that would be ambiguous. Document this
      behavior so that users know they must choose one or the other.

- **URI Clarity:**
  The examples use values like `package_a` and `package_b` for the `uri`.
    - **Suggestion:** Consider recommending the full `package:` URI (e.g.
      `package:package_a/package_a.dart`) in the documentation, unless your
      generator is meant to resolve short names internally. This can help avoid
      confusion about which file is being exported.

- **Tag Matching:**
  When specifying tags on an export configuration, clarify how the matching
  works. For example, does an export with `tags: ['core', 'utils']` get
  included in any barrel file that has at least one of those tags, or only
  those that have *both*? Being explicit about whether the tag match is an “OR”
  or “AND” operation will help users configure their projects correctly.

---

## 5. Documentation and Examples

- **Generated Output Examples:**
  Including sample output for various configuration scenarios (especially when
  multiple tags and barrel files are involved) could help users understand
  exactly how the generator works. For example, show a before‑and‑after for a
  library with several annotated elements, and explain which barrel file each
  element ends up in.

- **Error Handling and Warnings:**
  Document the expected behavior when conflicts or misconfigurations occur. For
  instance, what happens if two barrel files are configured with overlapping
  tags that lead to duplicate exports? Being upfront about error messages or
  warnings can save users time during integration.

- **Extensibility Considerations:**
  If you plan to add further customization (like header comments, custom
  formatting, or aliasing exports), it may be useful to mention that in the
  documentation as “future features” or provide extension points that advanced
  users can tap into.

---

## 6. Advanced Features to Consider

- **Alias Support:**
  Sometimes it’s useful to export an element under a different name (aliasing).
  If this is a desired use‑case, consider supporting an option for aliasing
  individual exports either in the annotation or in the builder configuration.

- **Selective Library Exporting:**
  For library-level annotations (e.g. annotating a whole library), clarify if
  the generator should export *all* public members, or if there’s any filtering
  available. In larger libraries, users might want more granular control.

- **Conflict Resolution:**
  Think about how the generator should behave if two annotated elements from
  different libraries have the same name. While this is largely a concern for
  the Dart analyzer and not your generator per se, a note in the documentation
  about best practices can be very useful.
