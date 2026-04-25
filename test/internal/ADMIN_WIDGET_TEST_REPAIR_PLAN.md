# Admin Widget Test Repair Plan

**Document role:** Historical defect/repair planning artifact  
**Project:** ShopEase  
**Created:** 2026-04-23  
**Current note:** This document is retained as historical evidence for the admin widget-test defect described in `test/TESTING_REPORT.md`. Current test counts are maintained in the master report, not here.

---

## 1. Historical Problem Statement

At the time this repair plan was created, six admin widget tests were failing. The failures were concentrated in:

- `test/widget/admin/add_product_screen_test.dart`
- `test/widget/admin/edit_product_screen_test.dart`
- `test/widget/admin/manage_bank_details_screen_test.dart`

The dominant failure pattern was:

```text
StateError: Bad state: No element
```

This occurred when the test framework tried to use a finder that matched no `TextFormField`.

---

## 2. Historical Root-Cause Hypothesis

The suspected root cause was a test-side finder anti-pattern:

```dart
find.widgetWithText(TextFormField, '<label>')
```

The production `CustomTextField` renders its label as a sibling `Text` widget above the `TextFormField`, not as `InputDecoration.labelText`. Therefore, searching for a `TextFormField` "with" that label text returns zero matches.

---

## 3. Repair Policy

The repair plan required a test-side-first approach:

1. Inspect production widgets read-only.
2. Confirm the actual widget tree.
3. Replace invalid finders with deterministic test-side finders.
4. Add visibility/pump sequencing where needed.
5. Avoid production changes unless a stable key was the only reasonable option.

No broad production refactor or business-logic change was permitted.

---

## 4. Historical Acceptance Criteria

The repair was considered complete when:

- The six failing admin widget tests passed.
- Existing passing admin tests were not regressed.
- The widget suite passed with 0 failures and 0 skips.
- Any production-code change, if required, was minimal and testability-only.

The companion completion artifact is `test/ADMIN_WIDGET_TEST_REPAIR_TASK.md`.

---

## 5. Current Evidence Reference

The 2026-04-23 documentation audit executed:

```powershell
flutter test test\widget
```

Result:

- 241 widget tests passed.
- 0 failed.
- 0 skipped.
- Non-fatal hit-test warnings were printed for some off-screen taps.

For current system-wide status, use `test/TESTING_REPORT.md`.
