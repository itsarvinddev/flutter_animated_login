## What this changes

<!-- One or two sentences. If it fixes an issue, write "Fixes #123". -->

## Why

<!-- The behaviour that was wrong, or the thing that could not be built. -->

## Checklist

- [ ] `dart format .` — the package is formatted at the **default 80 columns**;
      do not pass `--line-length`.
- [ ] `flutter analyze lib test` is clean, including info-level lints.
- [ ] `flutter test` passes, and behaviour changes come with a test in `test/`.
- [ ] Public members have doc comments.
- [ ] New user-facing strings live on `FormMessages`, not inline in a widget.
- [ ] `CHANGELOG.md` has an entry if this is visible to users of the package.

## Screenshots

<!-- Required for visual changes. Light and dark, and ideally at a 2x text
     scale, since the layouts are expected to survive it. -->

## Breaking changes

<!-- Any removed or renamed public API, any changed default. Write "None" if
     there are none. If there are, say what a caller has to do instead and add
     it to MIGRATION.md. -->
